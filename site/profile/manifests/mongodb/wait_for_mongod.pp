define profile::mongodb::wait_for_mongod (
  $operation = $name,
) {
  if ($::profile::mongodb::service_ensure == 'running') or ($::profile::mongodb::service_ensure == 'present') {
    # when mongod is checking databases, there is at least 3 processes
    exec { "Wait for MongoDB to be fully started ${operation}":
      command   => 'pgrep mongod | wc -l | grep -q ^1$',
      path      => '/bin',
      tries     => 120,
      try_sleep => 10,
      unless    => 'pgrep mongod | wc -l | grep -q ^0$'
    }
  }
}
