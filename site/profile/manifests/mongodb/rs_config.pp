class profile::mongodb::rs_config (
  $replset_name = $::profile::mongodb::replset_name,
  $db_address = 'admin',
  $username   = undef,
  $password   = undef,
  $replset_settings = {},
) {

  if $replset_name != undef and !empty($replset_settings){
    $lock_file = '/var/lock/mongo_rs_config_lock'
    $_replset_settings = inline_template("<%- require 'json' -%>
<%= (@replset_settings).to_json -%>")
    $mongo_cmd = "cfg = rs.conf();
cfg.[\"settings\"] = ${_replset_settings};
rs.reconfig(cfg);"
    if $username == undef or $password == undef {
      $reconfig_mongo_cmd = "/usr/bin/mongo ${db_address} --eval '${mongo_cmd}' && touch ${lock_file}"
    } else {
      $reconfig_mongo_cmd = "/usr/bin/mongo ${db_address} -u ${username} -p ${password} --eval '${mongo_cmd}' && touch ${lock_file}"
    }
    exec { 'Configure ReplicationSet settings':
      command => $reconfig_mongo_cmd,
      creates => $lock_file
    }
  }
}
