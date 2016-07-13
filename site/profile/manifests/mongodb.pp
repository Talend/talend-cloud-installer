#
# Sets up the mongodb instance
#
class profile::mongodb {

  require ::profile::common::packages
  require ::mongodb::client

  include ::profile::common::concat

  profile::register_profile { 'mongodb': }

  class { '::mongodb::server':
    verbose => true,
    auth    => true,
  }

  contain ::mongodb::server

}
