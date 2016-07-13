#
# Sets up a server, creates hiera-defined databases and role
#
class profile::postgresql(

  $pg_role_user          = undef,
  $pg_role_user_password = undef,
  $pg_role_db_name       = undef,

) {

  require postgresql::server
  require postgresql::client
  require profile::postgresql::databases

  class { 'profile::postgresql::role_user':
    pg_role_user          => $pg_role_user,
    pg_role_user_password => $pg_role_user_password,
    pg_role_db_name       => $pg_role_db_name,
  }

  contain profile::postgresql::role_user

}
