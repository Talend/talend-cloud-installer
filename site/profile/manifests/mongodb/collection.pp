#
# Creates a MongoDB collection
# @see https://docs.mongodb.com/manual/reference/method/db.createCollection
#
define profile::mongodb::collection (

  $collection_name = $name,
  $db_address      = undef,
  $options         = {},
  $create_index    = false,
  $index_keys      = {},
  $index_options   = {},
) {
  require profile::mongodb::is_primary

  if empty($db_address) {
    notice("Skipping creating MongoDB collection ${name} : empty db address")
  } else {
    $options_str = regsubst(to_json_ex($options), '\"', '\\"', 'G')
    $index_keys_str = regsubst(to_json_ex($index_keys), '\"', '\\"', 'G')
    $index_options_str = regsubst(to_json_ex($index_options), '\"', '\\"', 'G')

    if $::profile::mongodb::mongo_auth_already_enabled or $::profile::mongodb::mongo_auth_asked {
      $create_coll_cmd = "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
        db.createCollection('${collection_name}', ${options_str});\""

      $create_index_cmd = "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
        db.${collection_name}.createIndex(${index_keys_str}, ${index_options_str});\""

      $verify_coll_cmd = "mongo --norc --quiet admin -u ${::profile::mongodb::admin_user} \
        -p ${::profile::mongodb::admin_password} \
        --eval \"db=db.getSiblingDB('${db_address}'); \
        printjson(db.getCollectionNames());\" | grep -q '\"${collection_name}\"'"
    } else {
      $create_coll_cmd = "mongo --norc --quiet ${db_address} \
        --eval \"db.createCollection('${collection_name}', ${options_str});\""

      $create_index_cmd = "mongo --norc --quiet ${db_address} \
        --eval \"db.${collection_name}.createIndex(${index_keys_str}, ${index_options_str});\""

      $verify_coll_cmd = "mongo --norc --quiet ${db_address} \
        --eval \"printjson(db.getCollectionNames());\" | grep -q '\"${collection_name}\"'"
    }

    exec { "Create collection: ${collection_name} for ${name} in ${db_address}":
      path    => '/bin:/usr/bin',
      command => $create_coll_cmd,
      unless  => $verify_coll_cmd,
      onlyif  => "grep -q true ${::profile::mongodb::is_primary::primary_flag_file}"
    }

    if str2bool($create_index) {
      exec { "Create index: ${name} for ${collection_name}":
        command => $create_index_cmd,
        require => Exec["Create collection: ${collection_name} for ${name} in ${db_address}"]
      }
    }
  }
}
