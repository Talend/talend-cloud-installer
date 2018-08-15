class profile::mongodb::users (
  $users = {},
) {
  if $::profile::mongodb::service_ensure == 'running' or $::profile::mongodb::service_ensure == 'present' {
      create_resources('profile::mongodb::user', $users)
  }
}
