#
# Sets up the nexus instance
#
class profile::nexus (

  $nexus_root       = '/srv',
  $nexus_nodes      = '', # A string f.e. '[ "10.0.2.12", "10.0.2.23" ]'
  $nexus_nodes_port = '8081',
  $storage_device   = undef,
  $storage_data_device = undef,
  $nexus_data_root  = '/data',
) {

  require ::profile::java
  require ::profile::common::packages

  include ::nginx
  include ::profile::common::concat
  # $nexus_root configured in hiera for monitoring
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'nexus': }

  if $::osfamily == 'RedHat' and $::selinux == 'true' {
    selinux::boolean { 'httpd_can_network_connect':
      ensure => 'on',
    }
    selinux::boolean { 'httpd_setrlimit':
      ensure => 'on',
    }

    selinux::module { 'nginx':
      content => '
module nginx 1.0;
require {
        type httpd_t;
        type transproxy_port_t;
        class tcp_socket name_connect;
}
allow httpd_t transproxy_port_t:tcp_socket name_connect;
'
    }
  }

  if $nexus_nodes_port {
    $_nexus_nodes_port = $nexus_nodes_port
  } else {
    $_nexus_nodes_port = '8081'
  }

  $java_memory = floor($::memorysize_mb * 0.75)

  profile::common::mount_device { 'nexus_storage':
    device  => $storage_device,
    path    => $nexus_root,
    options => 'noatime,nodiratime'
  } ->
  profile::common::mount_device { 'nexus_second_storage':
    device  => $storage_data_device,
    path    => $nexus_data_root,
    options => 'noatime,nodiratime,rw,nouuid'
  } ->
  class { '::nexus':
    version         => '2.14.8',
    revision        => '01',
    nexus_root      => $nexus_root, # All directories and files will be relative to this
    nexus_port      => $_nexus_nodes_port,
    java_initmemory => $java_memory,
    java_maxmemory  => $java_memory
  }
  contain ::nexus

  # [ "10.0.2.12:8081", "10.0.2.23:8081" ]
  $_nexus_nodes = suffix(
    unique(
      concat(
        [$::ipaddress],
        split(regsubst($nexus_nodes, '[\s\[\]\"]', '', 'G'), ',')
      )
    ),
    ":${_nexus_nodes_port}"
  )

  class { 'profile::nexus::nginx':
    nexus_nodes => $_nexus_nodes,
  }
  class { 'profile::nexus::nexus_mem_check':
  }
}
