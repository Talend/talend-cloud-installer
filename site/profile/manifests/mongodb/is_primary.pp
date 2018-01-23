class profile::mongodb::is_primary (
  $primary_flag_file = "${::profile::mongodb::dbpath}/mongo_is_primary.flag"
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
      exec { 'wait_for_cluster_stabilization_on_creation':
        path    => '/bin:/usr/bin',
        command => "sleep 90 && touch ${primary_flag_file}",
        creates => $primary_flag_file
      }
      if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
        exec { 'primary_flag_with_auth':
          path    => '/bin:/usr/bin',
          command => "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
          -p ${::profile::mongodb::admin_password} --eval \"printjson(db.isMaster().ismaster);\" \
          | grep -q '^true$' \
          && echo \"true\" > ${primary_flag_file} \
          || echo \"false\" > ${primary_flag_file}",
          require => Exec['wait_for_cluster_stabilization_on_creation']
        }
      } else {
        exec { 'primary_flag_without_auth':
          path    => '/bin:/usr/bin',
          command => "mongo --norc --quiet admin --eval \"printjson(db.isMaster().ismaster);\" \
          | grep -q '^true$' \
          && echo \"true\" > ${primary_flag_file} \
          || echo \"false\" > ${primary_flag_file}",
          require => Exec['wait_for_cluster_stabilization_on_creation']
        }
      }
    }
  }
}
