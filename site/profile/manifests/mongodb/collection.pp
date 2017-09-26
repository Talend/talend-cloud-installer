#
# Creates a MongoDB collection
# @see https://docs.mongodb.com/manual/reference/method/db.createCollection
#
define profile::mongodb::collection (

  $collection_name = $name,
  $db_address      = $::profile::mongodb::collections::db_address,
  $options         = {},
  $create_index    = false,
  $index_keys      = {},
  $index_options   = {},

) {

  if $db_address {
    $lock_name = "/var/lock/mongo_${db_address}_${collection_name}_collection_lock"
    $lock_index_name = "/var/lock/mongo_${db_address}_${name}_index_lock"
    $options_str = regsubst(to_json_ex($options), '\"', '\\"', 'G')
    $index_keys_str = regsubst(to_json_ex($index_keys), '\"', '\\"', 'G')
    $index_options_str = regsubst(to_json_ex($index_options), '\"', '\\"', 'G')

    $create_coll_cmd = "/usr/bin/mongo \
      ${db_address} --eval \"db.createCollection('${collection_name}', ${options_str});\" \
      && /bin/touch ${lock_name}"

    if str2bool($create_index) {
      $create_index_cmd = "/usr/bin/mongo \
      ${db_address} --eval \"db.${collection_name}.createIndex(${index_keys_str}, ${index_options_str});\" \
      && /bin/touch ${lock_index_name}"
    }

    exec { "Create collection: ${collection_name} for ${name} in ${db_address}":
      command => $create_coll_cmd,
      creates => $lock_name,
    }

    if str2bool($create_index) {
      exec { "Create index: ${name} for ${collection_name}":
        command => $create_index_cmd,
        creates => $lock_index_name,
        require => Exec["Create collection: ${collection_name} for ${name} in ${db_address}"],
      }
    }

  } else {
    notice("Skipping creating MongoDB collection ${name} : empty db address")
  }

}
