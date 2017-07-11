#
# Sets up the mongodb instance
#
class profile::mongodb (

  $mongodb_nodes       = "[ ${::ipaddress} ]", # A string f.e. '[ "10.0.2.12", "10.0.2.23" ]'
  $shared_key          = undef,
  $replset_auth_enable = false,
  $service_ensure      = 'running',
  $service_enable      = true,
  $dbpath              = '/var/lib/mongo',
  $storage_device      = undef,
  $users               = {},
  $roles               = {},
  $collections         = {},
) {

  require ::profile::common::packages

  include ::logrotate
  include ::profile::common::concat
  # $dbpath configured in hiera for monitoring
  # FIXME rework cloudwatch to add defines and so manage easily each mount in each profiles
  include ::profile::common::cloudwatch

  profile::register_profile { 'mongodb': }

  # A list of strings, like ['10.0.2.12:27017', '10.0.2.23:27017']
  $_mongo_nodes = suffix(split(regsubst($mongodb_nodes, '[\s\[\]\"]', '', 'G'), ','), ':27017')
  $_mongo_auth_enable = str2bool($replset_auth_enable)

  # explicitly only support replica sets of size 3
  if size($_mongo_nodes) == 3 {
    $replset_name = 'tipaas'

    $replset_config = {
      'tipaas' => {
        ensure  => 'present',
        members => $_mongo_nodes
      }
    }

    if $_mongo_auth_enable == true {
      $keyfile = '/var/lib/mongo/shared_key'
    } else {
      $keyfile = undef
    }
  } else {
    $mongo_replset_name = undef
    $replset_name = undef
  }

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $dbpath,
    options => 'noatime,nodiratime,noexec'
  } ->
  class {'::mongodb::globals':
    manage_package_repo => true,
  }->
  file { 'ensure mongodb pid file directory':
    ensure => directory,
    path   => '/var/run/mongodb',
    mode   => '0777',
  } ->
  class { '::mongodb::server':
    verbose        => true,
    auth           => $_mongo_auth_enable,
    bind_ip        => [$::ipaddress, '127.0.0.1'],
    replset        => $replset_name,
    replset_config => $replset_config,
    key            => $shared_key,
    keyfile        => $keyfile,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
    dbpath         => $dbpath,
    dbpath_fix     => true,
  } ->
  class { '::mongodb::client':
  } ->
  class { '::profile::mongodb::roles':
    roles => $roles,
  } ->
  class { '::profile::mongodb::users':
    users => $users,
  } ->
  class { '::profile::mongodb::collections':
    collections => $collections,
  }

  if $storage_device {
    class { '::profile::common::mount_device::fixup_ownership':
      path                    => $dbpath,
      owner                   => 'mongod',
      group                   => 'mongod',
      fixup_ownership_require => Package['mongodb_server']
    }
  }

  contain ::mongodb::server
  contain ::mongodb::client

}
