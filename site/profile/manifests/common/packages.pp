#
# Installs hiera-defined common_packages
#
class profile::common::packages {

  require ::profile::common::packagecloud_repos
  require ::pip
  ensure_packages({
    'epel-release' => { ensure => 'present'},
  })

  create_resources(
    Package,
    hiera_hash('common_packages', {require => Package['epel-release']})
  )
}
