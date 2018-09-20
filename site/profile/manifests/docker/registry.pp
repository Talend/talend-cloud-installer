#
# Installing Docker registry
#
class profile::docker::registry (

  $ensure            = 'installed',
  $running           = true,
  $image             = 'registry:2',
  $storage_driver    = 'filesystem',
  $filesystem_device = undef,
  $filesystem_path   = '/var/lib/registry',
  $s3_region         = 'us-east-1',
  $s3_bucket         = undef,
  $s3_prefix         = undef,
  $env               = {},
  $registries        = {},

) {

  require ::profile::docker::host

  if 'absent' != $ensure {
    profile::register_profile { 'docker_registry': }

    if 'filesystem' == $storage_driver {
      validate_absolute_path($filesystem_path)

      file { 'Docker registry : ensure filesystem_path':
        ensure => directory,
        path   => $filesystem_path,
      } ->
      class { '::profile::common::mount_device':
        device  => $filesystem_device,
        path    => $filesystem_path,
        options => 'noatime,nodiratime',
        before  => Docker::Run['registry'],
      }

      $options = {
        'REGISTRY_STORAGE'                          => 'filesystem',
        'REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY' => '/data',
      }
      $volumes = [
        "${filesystem_path}:/data",
      ]
    } elsif 's3' == $storage_driver {
      validate_string($s3_region)
      validate_string($s3_bucket)
      validate_string($s3_prefix)

      $options = {
        'REGISTRY_STORAGE'                  => 's3',
        'REGISTRY_STORAGE_S3_REGION'        => $s3_region,
        'REGISTRY_STORAGE_S3_BUCKET'        => $s3_bucket,
        'REGISTRY_STORAGE_S3_ROOTDIRECTORY' => $s3_prefix,
      }
      $volumes = []
    }

    docker::run { 'registry':
      running => $running,
      image   => $image,
      ports   => '127.0.0.1:5000:5000',
      volumes => $volumes,
      env     => join_keys_to_values(merge($options, $env), '='),
    }

    # Configure access to authenticated registries
    file { '/root/.docker':
      ensure => 'directory',
      owner  => 'root',
      mode   => '0750',
    } ->
    file { '/root/.docker/config.json':
      ensure  => 'file',
      content => template('profile/root/.docker/config.json.erb'),
      mode    => '0600',
    }

  } else {
    notice('Skipping Docker Registry initialization due to the ensure parameter was set to absent.')
  }

}
