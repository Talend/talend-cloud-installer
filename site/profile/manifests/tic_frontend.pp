#
# TIC Frontend profile
#
class profile::tic_frontend (

  $version = undef,
  $region  = undef,

) {

  include ::logrotate
  include ::profile::common::concat

  profile::register_profile { 'tic_frontend': }

  if size($version) > 0 {
    $_version = $version
  } else {
    $_version = 'installed'
  }

  if size($region) > 0 {
    $_pendo_region = $region
  } else {
    $_pendo_region = 'NoRegion'
  }

  class { '::tic::frontend':
    pendo_cloud_provider => 'AWS',
    pendo_region         => $_pendo_region,
    version              => $_version,
  }

  contain ::tic::frontend

  if $::environment == 'ami' {
    class { 'profile::build_time_facts':
      facts_hash => {
        'ipaas_frontend_build_version' => $_version,
        'tic_frontend_version'         => $_version,
      }
    }
  }

}
