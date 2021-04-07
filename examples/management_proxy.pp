File { backup => false }
Package {
  allow_virtual => true,
}
Exec {
  path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
}
class {'elasticsearch':
  manage_repo  => true,
  java_install => true,
  repo_version => '2.x'
} ->
elasticsearch::instance { 'es-01': } ->
class { 'role::management_proxy': }
