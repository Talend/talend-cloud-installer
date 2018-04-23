#
# Docker Host profile
#
class profile::docker::host (

  $storage_device = undef,

) {

  profile::register_profile { 'docker_host': }

  sysctl {
    'net.ipv4.conf.all.route_localnet':
      value => '1';

    'vm.max_map_count':
      value => '262144' # this value is specific for elasticsearch services needs
  }

  if $storage_device {
    class { '::profile::docker::direct_lvm':
      storage_device => $storage_device,
      vg_name        => 'docker',
      lv_data_name   => 'data',
    }

    $storage_driver           = 'devicemapper'
    $dm_thinpooldev           = '/dev/mapper/docker-data'
    $dm_use_deferred_removal  = true
    $dm_use_deferred_deletion = true
  } else {
    $storage_driver           = undef
    $dm_thinpooldev           = undef
    $dm_use_deferred_removal  = undef
    $dm_use_deferred_deletion = undef
  }

  class { '::docker':
    use_upstream_package_source => true,
    storage_driver              => $storage_driver,
    dm_thinpooldev              => $dm_thinpooldev,
    dm_use_deferred_removal     => $dm_use_deferred_removal,
    dm_use_deferred_deletion    => $dm_use_deferred_deletion,
    repo_opt                    => '',
    icc                         => false,
    iptables                    => true,
    require                     => Sysctl['net.ipv4.conf.all.route_localnet', 'vm.max_map_count'],
  }

  # Monitor Docker daemon & containers
  class { 'monitoring::cadvisor':
    require => Class['::docker']
  }
}
