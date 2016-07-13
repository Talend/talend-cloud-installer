#
# Zookeeper service profile
#
class profile::zookeeper {

  require ::profile::common::packagecloud_repos
  require ::profile::java

  include ::profile::common::concat

  profile::register_profile { 'zookeeper': }

  class { '::zookeeper':
  }
  contain ::zookeeper

}
