# The base profile should include component modules that will be on all nodes
#
# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::base {

  require ::profile::common::packagecloud_repos
  require ::profile::common::packages
  require ::profile::common::cloudwatchlogs

  include ::profile::common::concat

  profile::register_profile { 'base': order => 1, }

  if $::osfamily == 'RedHat' { include ::selinux }
  if $::ec2_metadata { include ::awscli }

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

}
