class profile::mongodb::is_primary (
  $primary_flag_file = '/tmp/mongo_is_primary.flag'
) {

  # $mongo_is_writable if we can write on this Mongo
  if ($::profile::mongodb::service_ensure == 'running') or ($::profile::mongodb::service_ensure == 'present') {
    if empty($::profile::mongodb::replset_name) {
      file { $primary_flag_file:
        ensure  => file,
        content => 'true'
      }
    } else {
      # We need to know if we are on the primary server
      file { $primary_flag_file:
        ensure  => file
      }
      if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
        exec { 'primary_flag_with_auth':
          path    => '/bin:/usr/bin',
          command => "mongo --quiet admin -u ${::profile::mongodb::admin_user} \
          -p ${::profile::mongodb::admin_password} --eval \"db.isMaster();\" \
          | grep -q '\"ismaster\" : true' \
          && echo \"true\" > ${primary_flag_file} \
          || echo \"false\" > ${primary_flag_file}"
        }
      } else {
        exec { 'primary_flag_without_auth':
          path    => '/bin:/usr/bin',
          command => "mongo --quiet admin --eval \"db.isMaster();\" \
          | grep -q '\"ismaster\" : true' \
          && echo \"true\" > ${primary_flag_file} \
          || echo \"false\" > ${primary_flag_file}"
        }
      }
    }
  } else {
    file { $primary_flag_file:
      ensure => absent
    }
  }
}
