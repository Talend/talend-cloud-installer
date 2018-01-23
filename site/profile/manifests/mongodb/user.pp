#
# Creates a MongoDB user
# @see https://docs.mongodb.com/manual/reference/method/db.createUser
#
define profile::mongodb::user (
  $username   = $name,
  $password   = undef,
  $db_address = 'admin',
  $roles      = [], # an array of hashes, like [{'role'=>'userAdminAnyDatabase', 'db'=>'admin'}, {'role'=>'dbOwner', 'db'=>'ipaas'}]
) {
  require profile::mongodb::is_primary

  if empty($password) {
    notice("Skipping creating MongoDB user ${username} : empty password")
  } else {
    $roles_str = regsubst(to_json_ex($roles), '\"', '\\"', 'G')

    if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
      $create_user_cmd = "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
          db.createUser({ \
            user: '${username}', \
            pwd: '${password}', \
            roles: ${roles_str} \
          });\""
      $verify_cmd = "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
        printjson(db.getUser('${username}'));\" \
        | tr -d \"\t\n \" | grep -qv \"^null$\""
    } else {
      $create_user_cmd = "mongo --norc --quiet ${db_address} --eval \"db.createUser({ \
        user: '${username}', \
        pwd: '${password}', \
        roles: ${roles_str} \
      });\""
      $verify_cmd = "mongo --norc --quiet ${db_address} \
        --eval \"printjson(db.getUser('${username}'));\" \
        | tr -d \"\t\n \" | grep -qv \"^null$\""
    }

    exec { "Create MongoDB user : ${username}":
      path    => '/bin:/usr/bin',
      command => $create_user_cmd,
      unless  => $verify_cmd,
      onlyif  => "grep -q true ${::profile::mongodb::is_primary::primary_flag_file}"
    }
  }
}
