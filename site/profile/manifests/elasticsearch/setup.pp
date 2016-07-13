#
# Sets up elasticsearch instance
#
class profile::elasticsearch::setup (

  $plugins_hash   = undef,
  $security_group = 'not_available',
  $cluster_name   = undef,
  $heap_size      = undef,
  $config         = undef,

) {

  require ::profile::java
  require ::elasticsearch

  $userdata_json = parsejson($::ec2_userdata, {})

  if has_key($userdata_json,'cloud_formation') {
    $userdata_cloudformation = $userdata_json['cloud_formation']
    if has_key($userdata_cloudformation, 'elasticsearch_sg') {
      $userdata_sg = $userdata_cloudformation['elasticsearch_sg']
    }
  }

  $real_sg = pick($userdata_sg, $security_group)

  $userdata_config = {
    'discovery.ec2.groups' => $real_sg,
    'cluster.name'         => $cluster_name
  }
  $real_config = merge($config, $userdata_config)

  elasticsearch::instance { 'default':
    ensure        => present,
    status        => running,
    logging_level => INFO,
    config        => $real_config
  }

  # temporary fix for plugin version 2.5.1 https://github.com/elastic/elasticsearch-cloud-aws/issues/233
  staging::file {
    'joda-time-2.8.2.jar':
      source => 'http://central.maven.org/maven2/joda-time/joda-time/2.8.2/joda-time-2.8.2.jar'
  }

  # remove joda-time-2.7 and add joda-time-2.8.2
  file {
    '/usr/share/elasticsearch/plugins/cloud-aws/joda-time-2.8.2.jar':
      source  => '/opt/staging/profile/joda-time-2.8.2.jar',
      require => [
        Elasticsearch::Plugin['elasticsearch/elasticsearch-cloud-aws/2.5.1'],
        Staging::File['joda-time-2.8.2.jar']
      ],
      notify  => Service['elasticsearch-instance-default'];

    '/usr/share/elasticsearch/plugins/cloud-aws/joda-time-2.7.jar':
      ensure  => absent,
      require => Elasticsearch::Plugin['elasticsearch/elasticsearch-cloud-aws/2.5.1']
  }
  # end temporary fix

  if $plugins_hash {
    create_resources(elasticsearch::plugin, $plugins_hash)
  }

  unless empty($heap_size) {
    validate_re($heap_size, '\%$', 'The $heap_size variable does not seem to be a percentage, e.g. 50%')

    $heap_size_numeric = chop($heap_size)
    validate_numeric($heap_size_numeric, 95, 5)

    $calculated_heap_size = abs(floor($::memorysize_mb * ($heap_size_numeric / 100.0)))
    validate_integer($calculated_heap_size)

    augeas { 'elasticsearch':
      context => '/files/etc/sysconfig/elasticsearch-default',
      changes => "set ES_HEAP_SIZE ${calculated_heap_size}m",
      notify  => Elasticsearch::Instance['default'],
    }
  }

}
