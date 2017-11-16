#
# Creates a MongoDB role
# @see https://docs.mongodb.com/manual/reference/method/db.createRole
#
define profile::mongodb::role (
  $rolename   = $name,
  $db_address = 'admin',
  $privileges = [],
  $roles      = [],
) {
  require profile::mongodb::is_primary

  if empty($rolename) {
    notice('Skipping creating MongoDB role : empty rolename')
  } else {
    $privileges_str = regsubst(to_json_ex($privileges), '\"', '\\"', 'G')
    $roles_str      = regsubst(to_json_ex($roles), '\"', '\\"', 'G')

    if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
      $create_role_cmd = "mongo --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
          db.createRole({ \
          role: '${rolename}', \
          privileges: ${privileges_str}, \
          roles: ${roles_str} \
          });\""
      $verify_cmd = "mongo --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
        printjson(db.getRole('${rolename}'));\" \
        | tr -d \"\t\n \" | grep -qv \"^null$\""
    } else {
      $create_role_cmd = "mongo --quiet ${db_address} --eval \"db.createRole({ \
        role: '${rolename}', \
        privileges: ${privileges_str}, \
        roles: ${roles_str} \
        });\""
      $verify_cmd = "mongo --quiet ${db_address} --eval \"printjson(db.getRole('${rolename}'));\" \
        | tr -d \"\t\n \" | grep -qv \"^null$\""
    }
    exec { "Create MongoDB role : ${rolename}":
      path    => '/bin:/usr/bin',
      command => $create_role_cmd,
      unless  => $verify_cmd,
      onlyif  => "grep -q true ${::profile::mongodb::is_primary::primary_flag_file}",
      require => File[$::profile::mongodb::is_primary::primary_flag_file]
    }
  }
}
