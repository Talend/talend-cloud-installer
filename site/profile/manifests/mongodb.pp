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
  $admin_user          = undef,
  $admin_password      = undef,
  $users               = {},
  $roles               = {},
  $collections         = {},
) {

  require ::profile::common::packages

  include ::logrotate

  include ::profile::common::rsyslog
  include ::profile::common::concat
  # $dbpath configured in hiera for monitoring
  # FIXME rework cloudwatch to add defines and so manage easily each mount in each profiles
  include ::profile::common::cloudwatch
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'mongodb': }

  # A list of strings, like ['10.0.2.12:27017', '10.0.2.23:27017']
  $_mongo_nodes = suffix(split(regsubst($mongodb_nodes, '[\s\[\]\"]', '', 'G'), ','), ':27017')
  $mongo_auth_flag_path = "${dbpath}/mongo_auth.flag"

  $mongo_auth_already_enabled = str2bool(inline_template("<%= File.exist?('${mongo_auth_flag_path}') %>"))
  $mongo_auth_asked = str2bool($replset_auth_enable)

  if empty($admin_user) or empty($admin_password){
    $create_admin = false
  } else {
    $create_admin = true
  }

  swap_file::files { 'mongo_swap':
    ensure       => present,
    swapfile     => '/mnt/mongo.swap',
    swapfilesize => $::memorysize,
  }

  # explicitly only support replica sets of size 3
  if size($_mongo_nodes) == 3 {
    if empty($::mongodb_replset_name) {
      $replset_name = 'tipaas'
    } else {
      $replset_name = $::mongodb_replset_name
    }

    $replset_config = {
      "${replset_name}" => {
        ensure  => 'present',
        members => $_mongo_nodes
      }
    }

    if $mongo_auth_asked or $mongo_auth_already_enabled {
      $keyfile = '/var/lib/mongo/shared_key'
    } else {
      $keyfile = undef
    }
  } else {
    $replset_name = undef
  }

  file { 'mongod disable-transparent-hugepages':
    ensure => file,
    path   => '/etc/init.d/disable-transparent-hugepages',
    source => 'puppet:///modules/profile/etc/init.d/disable-transparent-hugepages',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    before => Class['::mongodb::server'],
    notify => [
      Exec['enable disable-transparent-hugepages'],
      Exec['start disable-transparent-hugepages']
    ]
  }

  exec { 'enable disable-transparent-hugepages':
    path        => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command     => 'chkconfig --add disable-transparent-hugepages',
    refreshonly => true,
    notify      => Exec['start disable-transparent-hugepages']
  }

  exec { 'start disable-transparent-hugepages':
    path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command => '/etc/init.d/disable-transparent-hugepages start',
    before  => Class['::mongodb::server']
  }

  exec { 'disable tuned for mongod':
    path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command => 'tuned-adm off',
    before  => Exec['start disable-transparent-hugepages'],
    onlyif  => 'which tuned-adm',
  }

  file { 'mongod sysctl conf':
    ensure => file,
    path   => '/etc/sysctl.d/mongod.conf',
    source => 'puppet:///modules/profile/etc/sysctl.d/mongod.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    before => Class['::mongodb::server'],
    notify => Exec['mongod sysctl apply']
  }

  exec { 'mongod sysctl apply':
    path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command => 'sysctl --system'
  }

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $dbpath,
    options => 'noatime,nodiratime,noexec',
    before  => Class['::mongodb::server']
  }

  if empty($::mongodb_version) {
    class {'::mongodb::globals':
      manage_package_repo => true,
      manage_pidfile      => false,
      before              => Class['::mongodb::client']
    }
  } else {
    class {'::mongodb::globals':
      version             => $::mongodb_version,
      manage_package_repo => true,
      manage_pidfile      => false,
      before              => Class['::mongodb::client']
    }
  }

  file { 'ensure mongodb pid file directory':
    ensure  => directory,
    path    => '/var/run/mongodb',
    mode    => '0755',
    owner   => 'mongod',
    group   => 'mongod',
    require => Package['mongodb_server'],
    before  => Class['mongodb::server::service']
  } ->
  file { 'ensure mongod user limits':
    ensure => file,
    path   => '/etc/security/limits.d/mongod.conf',
    source => 'puppet:///modules/profile/etc/security/limits.d/mongod.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  } ->
  rsyslog::snippet { '10_mongod':
    content => ":programname,contains,\"mongod\" /var/log/mongodb/mongod.log;CloudwatchAgentEOL\n& stop",
  }


  class { '::mongodb::client':
  } ->
  class { '::mongodb::server':
    auth           => $mongo_auth_already_enabled,
    bind_ip        => [$::ipaddress, '127.0.0.1'],
    replset        => $replset_name,
    replset_config => $replset_config,
    key            => $shared_key,
    keyfile        => $keyfile,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
    dbpath         => $dbpath,
    dbpath_fix     => true,
    logpath        => false,
    syslog         => true,
    create_admin   => $create_admin,
    admin_username => $admin_user,
    admin_password => $admin_password
  } ->
  profile::mongodb::wait_for_mongod { 'before auth':
  } ->
  class { '::profile::mongodb::auth':
    auth_already_enabled => $mongo_auth_already_enabled,
    auth_wanted          => $mongo_auth_asked,
  } ->
  profile::mongodb::wait_for_mongod { 'after auth':
  } ->
  class { '::profile::mongodb::roles':
    roles => $roles,
  } ->
  class { '::profile::mongodb::users':
    users => $users,
  } ->
  class { '::profile::mongodb::rs_config':
    replset_name => $replset_name,
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
