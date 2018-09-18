#!/bin/bash
# this file is managed by Puppet

###
# global vars (and default)
###
export SCRIPT_NAME=$(basename $0)
export _KAFKA_PATH=${KAFKA_PATH:-"/opt/kafka"}

###
# functions
###
# clean for quitting
fCloseAll (){
  if [ -n "${MYTMPDIR}" ] && [ -d ${MYTMPDIR} ];
  then
    rm -Rf ${MYTMPDIR}
  fi
}

#Show help
fShowHelp(){
  cat << EOF
  Script for managing kafka topics more easily
  Usage: 
    describe all topics: ${SCRIPT_NAME} -d
    describe specific topic name: ${SCRIPT_NAME} -d -t topic1,topic2
    redo sharding for all topics (but __consumer_offsets): ${SCRIPT_NAME} -s -b 1001,1002,1003
    redo sharding for two topics on 3 brokers: ${SCRIPT_NAME} -s -b 1001,1002,1003 -t topic1,topic2
    redo sharding with new partitioning (must be > to the current one): ${SCRIPT_NAME} -s -t topic1,topic2 -p 12 -b 1001,1002,1003
    options:
    -h : this help message
    -n : dryrun mode, only display what should be done
    -l : ask for topic list (mutually exclusive with -d and -s)
    -d : ask for topic description (mutually exclusive with -s and -d)
    -s : ask for topic resharding (mutually exclusive with -d and -l)
    -b id1,id2 : brokers id, mandatory with -s, ignored with -d
    -t topic1,topic2: topic filtering
    -r number: new replication facter for the topic

EOF
}

#Verify the parameters given
fVerifyParameters(){
  error_found=0
  if [ ! -f "${_KAFKA_PATH}/bin/kafka-topics.sh" ]; then
    echo "ERROR: can't find ${_KAFKA_PATH}/bin/kafka-topics.sh please verify or set KAFKA_PATH"
    error_found=$(expr $error_found + 1)
  fi
  if [ ! -f "${_KAFKA_PATH}/bin/kafka-configs.sh" ]; then
    echo "ERROR: can't find ${_KAFKA_PATH}/bin/kafka-configs.sh please verify or set KAFKA_PATH"
    error_found=$(expr $error_found + 1)
  fi
  exclusive_found=$((${_OPS_DESCRIBE} + ${_OPS_SHARDING} + ${_OPS_LIST}))
  if [ "${exclusive_found}" -eq 0 ]; then
    echo "ERROR: -l, -d or -s option is mandatory"
    error_found=$(expr $error_found + 1)
  fi
  if [ "${exclusive_found}" -gt 1 ]; then
    echo "ERROR: -l, -d and -s options are mutually exclusive"
    error_found=$(expr $error_found + 1)
  fi
  if [ "${_OPS_SHARDING}" -eq 1 ]; then
    if [ -z "${_BROKERSID}" ]; then
      echo "ERROR: -b is mandatory with -s"
      error_found=$(expr $error_found + 1)
    fi
  fi
  if [ ${error_found} -gt 0 ]; then
    fShowHelp
    exit 1
  fi
}

fDescribeTopics(){
  if [ -z "${_TOPICS}" ]; then
    unset topic_options
  else
    topic_options="--topic ${_TOPICS}"
  fi
  ${_KAFKA_PATH}/bin/kafka-topics.sh --zookeeper ${_ZOOKEEPER_PATH} --describe ${topic_options}
  return $?
}

#Verify topic(s) exists
fVerifyTopics(){
  topics=$(echo "${_TOPICS}" | sed 's/ //' | sed 's/,/ /g')
  topic_list=$(${_KAFKA_PATH}/bin/kafka-topics.sh --zookeeper ${_ZOOKEEPER_PATH} --list | grep -v "^__")
  ERROR=0
  for topic in $topics; do
    echo "${topic_list}" | grep -q "^${topic}$"
    test $? -ne 0 && echo "Topic ${topic} is unknown from the Kafka cluster" && ERROR=1
  done
  test ${ERROR} -eq 1 && exit ${ERROR}
}

#(re)shard topics
fShardTopics(){
  if [ -z ${_TOPICS} ]; then
    topics=$(${_KAFKA_PATH}/bin/kafka-topics.sh --zookeeper ${_ZOOKEEPER_PATH} --list | grep -v "^__")
  else
    topics=$(echo "${_TOPICS}" | sed 's/ //' | sed 's/,/ /g')
  fi
  if [ ! -z "${_PARTITIONS}" ]; then
    for topic in $topics; do
      fVerifPartitions $topic
    done
  fi
  # If we go there, the verifications were correct
  brokers=($(echo "${_BROKERSID}" | sed 's/ //' | sed 's/,/ /g'))
  brokers_size=${#brokers[*]}
  for topic in $topics; do
    if [ -z "${_REPLICAS}" ]; then
      replicas=$(fGetReplicationFactor $topic)
    else
      replicas=${_REPLICAS}
    fi
    if [ -z "${_PARTITIONS}" ]; then
      partitions=$(fGetPartitionCount $topic)
    else
      partitions=${_PARTITIONS}
    fi

    op_index=0
    idx_partition=$(($partitions - 1))
    echo '{' > ${MYTMPDIR}/${topic}.json
    echo '    "version":1,' >> ${MYTMPDIR}/${topic}.json
    echo '    "partitions":[' >> ${MYTMPDIR}/${topic}.json
    for ((i=0;i<=idx_partition;i++)); do
      echo -n '        {"topic":"'${topic}'","partition":'$i',"replicas":[' >> ${MYTMPDIR}/${topic}.json
      for ((j=1;j<=replicas;j++)); do
        echo -n ${brokers[$(($op_index % $brokers_size))]} >> ${MYTMPDIR}/${topic}.json
        test $(($j % $replicas)) -ne 0 && echo -n ',' >> ${MYTMPDIR}/${topic}.json
        op_index=$(($op_index + 1))
      done
      if [ $i -eq $idx_partition ]; then
        echo "]}" >> ${MYTMPDIR}/${topic}.json
      else
        echo "]}," >> ${MYTMPDIR}/${topic}.json
      fi
    done
    echo '    ]' >> ${MYTMPDIR}/${topic}.json
    echo '}' >> ${MYTMPDIR}/${topic}.json
  done

  for topic in $topics; do
    fChangePartitionNeeded $topic
    if [ $? -eq 1 ]; then
      fAlterPartitioning $topic
    fi
    fReassignPartition $topic
  done

  for topic in $topics; do
    fForceLeaders $topic
  done
}

#Alter partitioning for topic
fAlterPartitioning(){
  topic=$1
  if [ $DRYRUN -eq 0 ]; then
    echo "Change partioning for $topic from $(fGetPartitionCount $topic) to ${_PARTITIONS}"
    ${_KAFKA_PATH}/bin/kafka-topics.sh --zookeeper ${_ZOOKEEPER_PATH} --alter --topic ${topic} --partitions ${_PARTITIONS}
  else
    echo "Change partioning awaited for $topic from $(fGetPartitionCount $topic) to ${_PARTITIONS}"
  fi
}

# Get the PartitionCount value for topic
fGetPartitionCount(){
  topic=$1
  fDescribeTopics $topic | grep "^Topic:${topic}\s" | sed 's/.\+\sPartitionCount:\([0-9]\+\)\s.\+/\1/'
}

# Get the ReplicationFactor value for topic
fGetReplicationFactor(){
  topic=$1
  fDescribeTopics $topic | grep "^Topic:${topic}\s" | sed 's/.\+\sReplicationFactor:\([0-9]\+\)\s.\+/\1/'
}

#Return 0 if no change needed on partitions
fChangePartitionNeeded(){
  topic=$1
  current_partitions=$(fGetPartitionCount $topic)
  if [ ${_PARTITIONS} -eq ${current_partitions} ]; then
    return 0
  else
    return 1
  fi
}

#Verif the current operation is safe
fVerifPartitions(){
  topic=$1
  current_partitions=$(fGetPartitionCount $topic)
  if [ ${_PARTITIONS} -lt ${current_partitions} ]; then
    echo "WARNING: wanted partitions for ${topic} (${_PARTITIONS}) is lesser than current: ${current_partitions}, please, do it manually"
    if [ $DRYRUN -eq 0 ]; then
      exit 1
    fi
  fi
}

#Apply a given reassignement
fReassignPartition(){
  topic=$1
  if [ $DRYRUN -eq 1 ]; then
    echo "Awaited partition for $topic:"
    cat ${MYTMPDIR}/${topic}.json
  else
    ${_KAFKA_PATH}/bin/kafka-reassign-partitions.sh --zookeeper ${_ZOOKEEPER_PATH} --reassignment-json-file ${MYTMPDIR}/${topic}.json --execute
  fi
}

fForceLeaders(){
  topic=$1
  if [ $DRYRUN -eq 0 ]; then
    echo "Forcing leadership for topic ${topic}"
    ${_KAFKA_PATH}/bin/kafka-preferred-replica-election.sh --zookeeper ${_ZOOKEEPER_PATH} --path-to-json-file ${MYTMPDIR}/${topic}.json
  fi
}

###
# main part
###
_OPS_DESCRIBE=0
_OPS_LIST=0
_OPS_SHARDING=0
_TOPICS=""
_BROKERSID=""
_REPLICAS=""
_PARTITIONS=""
DRYRUN=0

export OPTIND=1
while getopts dlsb:t:r:p:hn opt
do
  case $opt in
    d )  export _OPS_DESCRIBE=1;;
    l )  export _OPS_LIST=1;;
    s )  export _OPS_SHARDING=1;;
    b )  export _BROKERSID=${OPTARG};;
    t )  export _TOPICS=${OPTARG};;
    r )  export _REPLICAS=${OPTARG};;
    p )  export _PARTITIONS=${OPTARG};;
    n )  export DRYRUN=1;;
    h )  fShowHelp; exit 0;;
    \?)  fShowHelp; exit 1;;
  esac
done

fVerifyParameters


export _ZOOKEEPER_PATH=$(sudo facter zookeeper_nodes | tr [ " " | tr ] /)$(sudo facter kafka_cluster_id)

if [ ${_OPS_LIST} -eq 1 ]; then
  ${_KAFKA_PATH}/bin/kafka-topics.sh --zookeeper ${_ZOOKEEPER_PATH} --list
  exit $?
fi

if [ ${_OPS_DESCRIBE} -eq 1 ]; then
  fDescribeTopics
  exit $?
fi

if [ ! -z "${_TOPICS}" ];
then
  fVerifyTopics
fi

MYTMPDIR=/tmp/$(basename $0 ".sh")_$(date +%Y%m%d%H%M%S)_$$
mkdir ${MYTMPDIR} && chmod 700 ${MYTMPDIR}
trap fCloseAll INT TERM EXIT

if [ ${_OPS_SHARDING} -eq 1 ]; then
  fShardTopics
fi
exit 0
