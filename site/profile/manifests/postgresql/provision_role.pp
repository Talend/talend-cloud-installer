#
# Provisions server with sql files
#
define profile::postgresql::provision_role {

  $role = $profile::postgresql::roles[$name]

  $role_safe = regsubst($name, '[^0-9a-zA-Z]', '_', 'G')
  $creates   = "/var/tmp/${role_safe}.provision.done"

  $host   = $profile::postgresql::hostname
  $user   = $name
  $pass   = pick($role['password'], $profile::postgresql::password)
  $dbname = $name

  $files = join(pick($role['files'], []), ' ')

  exec { "provision ${name} with files : exec":
    environment => "PGPASSWORD=${pass}",
    command     => "/usr/bin/cat ${files} | /usr/bin/psql -U ${user} -h ${host} -d ${dbname} -f - && touch ${creates}",
    creates     => $creates
  }
}
