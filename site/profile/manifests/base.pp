# The base profile should include component modules that will be on all nodes
#
# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::base {

  class { '::profile::common::packagecloud_repos':
  } ->
  class { '::profile::common::packages':
  } ->
  class { '::profile::common::cloudwatchlogs':
  } ->
  class { '::profile::common::ssm':
  }

  include ::profile::common::concat
  include ::profile::common::accounts
  include ::profile::common::logrotate

  include ::ntp

  include monitoring::node_exporter

  profile::register_profile { 'base': order => 1, }

  if $::osfamily == 'RedHat' and $::selinux == 'true' {
    include ::selinux
  }

  if $::ec2_metadata {
    include profile::common::helper_scripts
  }

  # Increase sshd log level to Verbose to log failed login attempts
  file_line { 'sshd_log_level':
    ensure => present,
    path   => '/etc/ssd/ssd_config',
    line   => 'LogLevel VERBOSE',
    match  => '^LogLevel ',
    after  => '^#LogLevel INFO',
  }

  # This distributes the custom fact to the host(-pluginsync)
  # on using puppet apply
  file { $::settings::libdir:
    ensure  => directory,
    source  => 'puppet:///plugins',
    recurse => true,
    purge   => true,
    backup  => false,
    noop    => false,
  }

  # Also needed for custom facts
  file {
    '/etc/facter':
      ensure => directory;

    '/etc/facter/facts.d':
      ensure  => directory,
      require => File['/etc/facter'];
  }
  create_resources('limits::fragment', hiera('limits::fragment', {}))
}
