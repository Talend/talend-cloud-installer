# Setting up the single mongodb instance
#
class profile::db::mongodb {

  unless defined(Package['epel-release']){
    package{ 'epel-release':
      ensure => 'present';
    }
  }

  class { '::mongodb::client': } ->
  class { '::mongodb::server':
    verbose => true,
    auth    => true,
  }

  mongodb::db { 'testdb':
    user          => 'user1',
    password_hash => 'a15fbfca5e3a758be80ceaf42458bcd8', #  'password_hash' is hex encoded md5 hash of "user1:mongo:pass1".
  }

}