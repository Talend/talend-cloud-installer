#
# MongoDB instance role
#
class role::mongodb {

  include ::profile::base
  include ::profile::common::hosts
  include ::profile::mongodb

  Class['::profile::base'] -> Class['::profile::common::hosts'] -> Class['::profile::mongodb']

  role::register_role { 'mongodb': }

}
