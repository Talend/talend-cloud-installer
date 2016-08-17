#
# Sets up the nexus instance
#
class profile::nexus (

  $nexus_root  = '/srv',
  $nexus_nodes = '',

) {

  require ::profile::java
  require ::profile::common::packages

  include ::nginx
  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'nexus': }

  class { '::nexus':
    version    => '2.8.0',
    revision   => '05',
    nexus_root => $nexus_root, # All directories and files will be relative to this
    nexus_port => '8081',
  }
  contain ::nexus

  # [ "10.0.2.12:8081", "10.0.2.23:8081" ]
  $_nexus_nodes = unique(
    concat(
      ["${::ipaddress}:8081"],
      split($nexus_nodes, ',')
    )
  )

  class { 'profile::nexus::nginx':
    nexus_nodes => $_nexus_nodes,
  }

}
