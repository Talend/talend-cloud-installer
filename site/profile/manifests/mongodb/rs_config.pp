class profile::mongodb::rs_config (
  $replset_name = $::profile::mongodb::replset_name,
  $replset_settings = {},
) {
  require profile::mongodb::is_primary
  if empty($replset_name) or empty($replset_settings){
    notice('MongoDB server: skipping replicationset config')
  } else {
    $_replset_settings = inline_template("<%- require 'json' -%>
<%= (@replset_settings).to_json -%>")
    $mongo_cmd = "cfg = rs.conf(); \
      cfg.[\"settings\"] = ${_replset_settings}; \
      rs.reconfig(cfg);"

    if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
      $reconfig_mongo_cmd = "mongo --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} --eval '${mongo_cmd}'"
    } else {
      $reconfig_mongo_cmd = "mongo --quiet admin --eval '${mongo_cmd}'"
    }

    exec { 'Configure ReplicationSet settings':
      path    => '/bin:/usr/bin',
      command => $reconfig_mongo_cmd,
      onlyif  => "grep -q true  ${::profile::mongodb::is_primary::primary_flag_file}"
    }
  }
}
