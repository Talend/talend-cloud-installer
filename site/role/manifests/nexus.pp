#
# Nexus Repository role
#
class role::nexus {

  include ::profile::base
  include ::profile::nexus

  role::register_role { 'nexus': }

}
