class profile::postgresql::install {

  class { 'postgresql::globals':
    version             => '9.5',
    encoding            => 'UTF8',
    locale              => 'en_NG',
    manage_package_repo => true,
  }

  $service_status = $profile::postgresql::service_ensure ? {
    stopped => 'test 1 -eq 2',
    default => undef,
  }

  class { 'postgresql::server':
    listen_addresses => '*',
    service_ensure   => $profile::postgresql::service_ensure,
    service_enable   => $profile::postgresql::service_enable,
    service_manage   => true,
    service_status   => $service_status,
  }

  contain ::postgresql::server
  contain ::postgresql::client

}
