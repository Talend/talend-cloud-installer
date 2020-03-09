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
  $swap_ensure         = 'present',
  $mongodb_yaml_profile_name = undef,
) {

  require ::profile::common::packages

  include ::logrotate

  include ::profile::common::rsyslog
  include ::profile::common::concat
  # $dbpath configured in hiera for monitoring
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'mongodb': }

  # A list of strings, like ['10.0.2.12:27017', '10.0.2.23:27017']
  $_mongo_nodes = suffix(split(regsubst($mongodb_nodes, '[\s\[\]\"]', '', 'G'), ','), ':27017')
  $mongo_auth_flag_path = "${dbpath}/mongo_auth.flag"

  $mongo_auth_asked = str2bool($replset_auth_enable)

  if empty($mongodb_yaml_profile_name){
    $_mongodb_yaml_profile_name = 'mongodb_default_profile'
  } else {
    $_mongodb_yaml_profile_name = $mongodb_yaml_profile_name
  }

  # We can overide stuff with extra_file (replacing master_password for example)
  $_mongodb_yaml_profile = hiera($_mongodb_yaml_profile_name, {})
  $_mongodb_yaml_profile_overrode = hiera("${_mongodb_yaml_profile_name}_overrode", {})
  $mongodb_yaml_profile = deep_merge($_mongodb_yaml_profile, $_mongodb_yaml_profile_overrode)

  # explicitly only support replica sets of size 3
  if size($_mongo_nodes) == 3 {
    if has_key($mongodb_yaml_profile, 'replset_name') {
      $replset_name = $mongodb_yaml_profile['replset_name']
    } else {
      $replset_name = 'tipaas'
    }

    $replset_config = {
      "${replset_name}" => {
        ensure  => 'present',
        members => $_mongo_nodes
      }
    }
  } else {
    $replset_name = undef
    $replset_config = undef
  }

  if has_key($mongodb_yaml_profile, 'storage_engine') {
    $storage_engine = $mongodb_yaml_profile['storage_engine']
  } else {
    $storage_engine = 'mmapv1'
  }

  if has_key($mongodb_yaml_profile, 'users') {
    $_users = deep_merge($users, $mongodb_yaml_profile['users'])
  } else {
    $_users = $users
  }

  if empty($admin_user) or empty($admin_password){
    $create_admin = false
  } else {
    $create_admin = true
  }

  if $mongo_auth_asked {
    if empty($shared_key) {
    } else {
      $keyfile = '/var/lib/mongo/shared_key'
    }
  } else {
    $keyfile = undef
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

  file { 'ensure mongod user limits':
    ensure => file,
    path   => '/etc/security/limits.d/mongod.conf',
    source => 'puppet:///modules/profile/etc/security/limits.d/mongod.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Exec['systemctl reload for mongo'],
    before => Class['mongodb::server']
  }

  exec { 'mongod sysctl apply':
    path        => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command     => 'sysctl --system',
    refreshonly => true
  }

  exec { 'systemctl reload for mongo':
    path        => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    before      => Class['::mongodb::server::service'],
    require     => Package['mongodb_server']
  }

  class { '::profile::mongodb::verify_auth':
    auth_wanted => $mongo_auth_asked,
    flag_file   => $mongo_auth_flag_path,
    require     => [Class['::profile::common::mount_device'], Class['::mongodb::server::config']],
    before      => Class['::mongodb::server::service']
  }

  class { '::profile::common::mount_device':
    device  => $storage_device,
    path    => $dbpath,
    options => 'noatime,nodiratime,noexec',
    before  => Class['::mongodb::server']
  }

  if empty($::mongodb_forced_version) {
    class {'::mongodb::globals':
      manage_package_repo => true,
      manage_pidfile      => false,
      before              => Class['::mongodb::client']
    }
  } else {
    if $::environment == 'ami' or $::environment == 'vagrant' {
      class { 'profile::build_time_facts':
        facts_hash => {
          'mongodb_forced_version' => $::mongodb_forced_version,
        }
      }
    }
    class {'::mongodb::globals':
      version             => $::mongodb_forced_version,
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
  rsyslog::snippet { '10_mongod':
    content => ":programname,contains,\"mongod\" /var/log/mongodb/mongod.log;CloudwatchAgentEOL\n& stop",
  }

  file { 'systemd-mongod-override':
    ensure  => file,
    path    => '/etc/systemd/system/mongod.service',
    source  => 'puppet:///modules/profile/etc/systemd/system/mongod.service',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Exec['systemctl reload for mongo'],
    require => Package['mongodb_server'],
    before  => Class['mongodb::server::service']
  }



  class { '::mongodb::client':
  } ->
  class { '::mongodb::server':
    auth           => $mongo_auth_asked,
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
    admin_password => $admin_password,
    storage_engine => $storage_engine,
    store_creds    => true,
  } ->
  profile::mongodb::wait_for_mongod { 'before auth':
  } ->
  class { '::profile::mongodb::auth':
    auth_wanted          => $mongo_auth_asked,
  } ->
  profile::mongodb::wait_for_mongod { 'after auth':
  } ->
  class { '::profile::mongodb::is_primary':
  } ->
  class { '::profile::mongodb::roles':
    roles => $roles,
  } ->
  class { '::profile::mongodb::users':
    users => $_users,
  } ->
  class { '::profile::mongodb::rs_config':
    replset_name => $replset_name,
  }

  if $storage_device {
    class { '::profile::common::mount_device::fixup_ownership':
      path                    => $dbpath,
      owner                   => 'mongod',
      group                   => 'mongod',
      fixup_ownership_require => Package['mongodb_server']
    }

    swap_file::files { 'mongo_swap':
      ensure       => $swap_ensure,
      swapfile     => "${dbpath}/mongo.swap",
      swapfilesize => $::memorysize,
      require      => Class['::profile::common::mount_device::fixup_ownership']
    }
  }

  contain ::mongodb::server
  contain ::mongodb::client
}
