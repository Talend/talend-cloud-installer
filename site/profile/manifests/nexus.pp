#
# Sets up the nexus instance
#
class profile::nexus (

  $nexus_root = '/srv',

) {

  require ::profile::java
  require ::profile::common::packages

  include ::profile::common::concat

  profile::register_profile { 'nexus': }

  class { '::nexus':
    version    => '2.8.0',
    revision   => '05',
    nexus_root => $nexus_root, # All directories and files will be relative to this
  }
  contain ::nexus

}
