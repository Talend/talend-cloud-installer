# The base profile should include component modules that will be on all nodes
#
# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::base {

  profile::register_profile{ 'base': order => 1, }

  # Ensure we have a yum repo first before we intall rpm packages ....
  Yumrepo <| |> -> Package <| |>

  # Ensure we have a path set for all possible execs
  # This is now limited to unixoid systems
  Exec {
    path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
  }

  # depreceated since concat 2.0
  # include concat::setup
  include ::stdlib

  if $::osfamily == 'RedHat' { include ::selinux }
  if $::ec2_metadata { include ::awscli }

  # get some usual helpers installed
  $common_packages = hiera_hash('common_packages', {})
  create_resources(Package, $common_packages)


  # This distributes the custom fact to the host(-pluginsync)
  # on using puppet apply
  file { $::settings::libdir:
    ensure  => directory,
    source  => 'puppet:///plugins',
    recurse => true,
    purge   => true,
    backup  => false,
    noop    => false
  }

  concat{ '/etc/sysconfig/puppetProfile':
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  concat{ '/etc/sysconfig/puppetRole':
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
}
