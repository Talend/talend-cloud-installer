#
# Zookeeper service role
#
class role::zookeeper {

  include ::profile::base
  include ::profile::zookeeper

  role::register_role { 'zookeeper': }

}
