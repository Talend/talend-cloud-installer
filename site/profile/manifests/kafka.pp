#
# Sets up the kafka instance
#

class profile::kafka (
  $kafka_version           = '0.10.2.1',
  $scala_version           = '2.11',
  $kafka_datapath          = '/var/lib/kafka',
  $storage_device          = undef,
  $zookeeper_nodes         = '[ "127.0.0.1" ]', # A string f.e. '[ "10.0.2.12", "10.0.2.23" ]'
  $zookeeper_port          = 2181,
  $kafka_cluster_id        = 'kafka-cluster',
  $kafka_broker_id         = '-1',         # Automatic id
  $kafka_broker_config     = {},
  $kafka_topics_config     = {},
  $kafka_topics_default_replication = 1,
  $kafka_topics_default_partitions  = 2,
  $kafka_topics_autocreate = false,
  $log_level               = 'INFO',
  $kafka_yaml_profile_name = '',
) {

  require ::profile::common::packages
  require ::profile::java
  include ::logrotate
  include ::profile::common::concat
  # FIXME rework cloudwatch to add defines and so manage easily each mount in each profiles
  include ::profile::common::cloudwatch
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'kafka': }

  $zookeeper_kafkapath = "/${kafka_cluster_id}"
  $zookeeper_cluster = join(
    suffix(
      split(regsubst($zookeeper_nodes, '[\s\[\]\"]', '', 'G'), ','),
      ":${zookeeper_port}"
    ), ','
  )
  $zookeeper_connect = "${zookeeper_cluster}${zookeeper_kafkapath}"

  $default_kafka_broker_config = {
    'broker.id'                     => $kafka_broker_id,
    'zookeeper.connect'             => $zookeeper_connect,
    'log.dir'                       => $kafka_datapath,
    'log.dirs'                      => $kafka_datapath,
    'inter.broker.protocol.version' => $kafka_version,
    'advertised.host.name'          => $::ipaddress,
    'auto.create.topics.enable'     => $kafka_topics_autocreate,
    'log.cleanup.policy'            => 'delete',
    'log.retention.bytes'           => '536870912', # 512M
    'log.retention.ms'              => '43200000',  #  12h
  }

  if empty($kafka_yaml_profile_name){
    $kafka_yaml_profile = {}
  } else {
    $kafka_yaml_profile = hiera($kafka_yaml_profile_name, {})
  }

  if has_key($kafka_yaml_profile, 'kafka_version') {
    $_kafka_version = $kafka_yaml_profile['kafka_version']
  } else {
    $_kafka_version = $kafka_version
  }

  if has_key($kafka_yaml_profile, 'scala_version') {
    $_scala_version = $kafka_yaml_profile['scala_version']
  } else {
    $_scala_version = $scala_version
  }

  if has_key($kafka_yaml_profile, 'log_level') {
    $_log_level = $kafka_yaml_profile['log_level']
  } else {
    $_log_level = $log_level
  }

  if has_key($kafka_yaml_profile, 'kafka_topics_default_replication') {
    $_kafka_topics_default_replication = $kafka_yaml_profile['kafka_topics_default_replication']
  } else {
    $_kafka_topics_default_replication = $kafka_topics_default_replication
  }

  if has_key($kafka_yaml_profile, 'kafka_topics_default_partitions') {
    $_kafka_topics_default_partitions = $kafka_yaml_profile['kafka_topics_default_partitions']
  } else {
    $_kafka_topics_default_partitions = $kafka_topics_default_partitions
  }

  if has_key($kafka_yaml_profile, 'kafka_broker_config') {
    $broker_config = deep_merge($default_kafka_broker_config, $kafka_broker_config, $kafka_yaml_profile['kafka_broker_config'])
  } else {
    $broker_config = deep_merge($default_kafka_broker_config, $kafka_broker_config)
  }

  if has_key($kafka_yaml_profile, 'topics') {
    $_kafka_topics_config = deep_merge($kafka_topics_config, $kafka_yaml_profile['topics'])
  } else {
    $_kafka_topics_config = $kafka_topics_config
  }

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $kafka_datapath,
    options => 'noatime,nodiratime,noexec',
  } ->
  class { '::kafka':
    version       => $_kafka_version,
    scala_version => $_scala_version,
    install_java  => false,
  } ->
  class { '::kafka::broker':
    config                     => $broker_config,
    service_requires_zookeeper => false
  }

  file { $kafka_datapath:
    ensure  => 'directory',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0750',
    require => [ User['kafka'], Group['kafka'] ],
    notify  => Service['kafka']
  }

  file { '/opt/kafka/config/log4j.properties':
    ensure  => 'present',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    content => template('profile/opt/kafka/config/log4j.properties.erb'),
    require => File['/opt/kafka/config'],
    notify  => Service['kafka']
  }

  # For debugging
  #  notice(inline_template("
  #<%- require 'json' -%>
  #<%= JSON.pretty_generate(@_kafka_topics_config) %>
  #"))

  unless empty($_kafka_topics_config) {
    exec { 'wait-for-kafka':
      command   => 'timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/9092"',
      tries     => 10,
      try_sleep => 10,
      path      => ['/bin', '/usr/bin'],
      require   => Service['kafka']
    }

    create_resources('::profile::kafka::broker_topic',
      $_kafka_topics_config,
      {
        replication_factor => $_kafka_topics_default_replication,
        partitions         => $_kafka_topics_default_partitions,
        require            => Exec['wait-for-kafka']
      }
    )
  }

  contain ::kafka::broker
}
