class profile::mongodb::auth (
  $auth_already_enabled = $::profile::mongodb::mongo_auth_already_enabled,
  $auth_wanted          = $::profile::mongodb::mongo_auth_asked,
  $service_ensure       = $::profile::mongodb::service_ensure,
) {

  if ($service_ensure == 'running') or ($service_ensure == 'present'){
    if $auth_wanted {
      if $auth_already_enabled {
        notice('Mongo already started with auth enabled')
      } else {
        exec { 'Enabling auth on MongoDB':
          command => 'sed -i \'s/^\s*security.authorization: .\+$/security.authorization: enabled/\' /etc/mongod.conf',
          path    => '/bin',
          notify  => Exec['restart_mongo']
        } ->
        file { $::profile::mongodb::mongo_auth_flag_path:
          ensure  => file,
          content => '# flag to launch mongo in auth mode',
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
        }
        # This is not done by service otherwice there is a circle dependancy.
        # this is a temporary state that Puppet can't manage
        exec { 'restart_mongo':
          path        => '/sbin:/usr/sbin',
          command     => 'service mongod restart',
          refreshonly => true,
        }
      }
    } else {
      if $auth_already_enabled {
        notice("Mongo auth is present please remove ${::profile::mongodb::mongo_auth_flag_path} if you want to cancel it")
      } else {
        notice('Mongo started without auth')
      }
    }
  }
}
