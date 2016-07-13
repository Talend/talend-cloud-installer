#
# Creates Postgresql hiera-defined databases
#
class profile::postgresql::databases {
  create_resources(
    'postgresql::server::database',
    hiera_hash('pg_databases', {})
  )
}
