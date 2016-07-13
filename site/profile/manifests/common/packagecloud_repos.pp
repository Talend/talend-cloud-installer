#
# Defines hiera-defined packagecloud repositories
#
class profile::common::packagecloud_repos {
  create_resources(
    'packagecloud::repo',
    hiera_hash('packagecloud_repos', {})
  )
}
