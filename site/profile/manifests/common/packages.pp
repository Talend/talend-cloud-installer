#
# Installs hiera-defined common_packages
#
class profile::common::packages {
  create_resources(
    Package,
    hiera_hash('common_packages', {})
  )
}
