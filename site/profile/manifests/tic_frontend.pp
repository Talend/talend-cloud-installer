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

  $pendo_regions = {
    'us-east-1'    =>  'US East (N. Virginia)',
    'eu-central-1' =>  'EU (Frankfurt)',
    'us-west-2'    =>  'US West (Oregon)',
    'eu-west-1'    =>  'EU (Ireland)',
  }
  if ( has_key($pendo_regions, $region) ) {
    $_pendo_region = $pendo_regions[$region]
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
