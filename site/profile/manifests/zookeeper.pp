#
# Zookeeper service profile
#
class profile::zookeeper (

  $zookeeper_nodes = '', # A string f.e. '[ "10.0.2.12", "10.0.2.23" ]'

) {

  require ::profile::common::packagecloud_repos
  require ::profile::java

  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs
  include monitoring::jmx_exporter

  profile::register_profile { 'zookeeper': }

  # "['10.72.4.7', '10.72.5.111', '10.72.6.51']" => ["10.72.4.7", "10.72.5.111", "10.72.6.51"]
  $_zookeeper_nodes = split(regsubst($zookeeper_nodes, '[\s\[\]\"]', '', 'G'), ',')
  $_zookeeper_ips   = concat([$::ipaddress], $_zookeeper_nodes)

  # ["10.72.4.7", "10.72.5.111", "10.72.6.51"] => ["ip-10-72-4-7", "ip-10-72-5-111", "ip-10-72-6-51"]
  $_zookeeper_ec2_hostnames = ip2ec2hostname($_zookeeper_ips)

  class { '::zookeeper':
    zookeeper_nodes => $_zookeeper_ec2_hostnames
  }

}
