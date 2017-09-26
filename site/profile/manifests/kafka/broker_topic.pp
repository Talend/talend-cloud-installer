# Example of hiera conf to call this ressource
# profile::kafka::kafka_topics_config:
#   mytopicwithdefault:
#     replication_factor: 2
#     partitions: 6
#   mytopic:
#     replication_factor: 2
#     partitions: 6
#     topic_options:
#       retention.bytes: 1073741824 #1GB
#       cleanup.policy: 'delete'
#       retention.ms: 18000000 #5 hours
define profile::kafka::broker_topic(
  $ensure             = 'present',
  $zookeeper          = $::profile::kafka::zookeeper_cluster,
  $zookeeper_path     = $::profile::kafka::zookeeper_kafkapath,
  $replication_factor = 1,
  $partitions         = 1,
  $topic_options      = {} #https://kafka.apache.org/documentation/#topic-config
) {

  $zookeeper_node_a   = values_at(split($zookeeper, ','), 0)

  $_zookeeper          = "--zookeeper ${zookeeper_node_a}${zookeeper_path}"
  $_replication_factor = "--replication-factor ${replication_factor}"
  $_partitions         = "--partitions ${partitions}"


  if $ensure == 'present' {
    $topic_create_options  = inline_template('<% unless @topic_options.empty? %><% @topic_options.each do |key, value| %> --config <%= key %>=<%= value %><% end %><% end %>')
    $topic_config_options  = inline_template('<% unless @topic_options.empty? %><% @topic_options.each do |key, value| %> --add-config <%= key %>=<%= value %><% end %><% end %>')

    unless empty($topic_options){
      exec { "configure topic ${name}":
        path    => '/usr/bin:/usr/sbin/:/bin:/sbin:/opt/kafka/bin',
        command => "kafka-configs.sh ${_zookeeper} --entity-type topics --entity-name ${name} --alter ${topic_config_options}",
        onlyif  => "kafka-topics.sh --list ${_zookeeper} | grep -x '^${name}$'",
      }
    }
    exec { "create topic ${name}":
      path    => '/usr/bin:/usr/sbin/:/bin:/sbin:/opt/kafka/bin',
      command => "kafka-topics.sh --create ${_zookeeper} ${_replication_factor} ${_partitions} --topic ${name} ${topic_create_options}",
      unless  => "kafka-topics.sh --list ${_zookeeper} | grep -x '^${name}$'",
    }
  } elsif $ensure == 'absent' {
    exec { "delete topic ${name}":
      path    => '/usr/bin:/usr/sbin/:/bin:/sbin:/opt/kafka/bin',
      command => "kafka-run-class.sh kafka.admin.TopicCommand ${_zookeeper} --delete --topic ${name}",
      onlyif  => "kafka-topics.sh --list ${_zookeeper} | grep -x '^${name}$'",
    }
  }
}
