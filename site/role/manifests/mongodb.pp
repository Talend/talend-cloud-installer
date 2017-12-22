#
# MongoDB instance role
#
class role::mongodb {

  include ::profile::base
  include ::profile::common::hosts
  include ::profile::mongodb

  role::register_role { 'mongodb': }

}
