#
# Sets up elasticsearch instance and waits for the service to start
#
class profile::elasticsearch(

  $plugins_hash   = undef,
  $security_group = 'not_available',
  $cluster_name   = undef,
  $heap_size      = undef,
  $config         = undef,

) {

  class { '::profile::elasticsearch::setup':
    plugins_hash   => $plugins_hash,
    security_group => $security_group,
    cluster_name   => $cluster_name,
    heap_size      => $heap_size,
    config         => $config,
  } ->
  class { '::profile::elasticsearch::wait':
  }

  contain ::profile::elasticsearch::setup
  contain ::profile::elasticsearch::wait

  include ::profile::common::concat

  profile::register_profile { 'elasticsearch': }

}
