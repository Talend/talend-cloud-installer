#
# Creates Postgresql role
#
class profile::postgresql::role_user (

  $pg_role_user          = undef,
  $pg_role_user_password = undef,
  $pg_role_db_name       = undef,

) {
  if $pg_role_user {
    postgresql_psql { "CREATE ROLE ${pg_role_user}":
      command          => "CREATE ROLE \"${pg_role_user}\" WITH LOGIN PASSWORD '\$NEWPGPASSWD'",
      unless           => "SELECT rolname FROM pg_roles WHERE rolname='${pg_role_user}'",
      environment      => "NEWPGPASSWD=${pg_role_user_password}",
      require          => Class['Postgresql::Server'],
      connect_settings => $postgresql::server::default_connect_settings
    } ->
    postgresql::server::database_grant { 'database_grant':
      privilege => 'ALL',
      db        => $pg_role_db_name,
      role      => $pg_role_user,
    }
  }
}
