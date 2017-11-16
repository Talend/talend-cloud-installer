class profile::mongodb::roles (
  $roles = {},
) {
  if $::profile::mongodb::service_ensure == 'running' or $::profile::mongodb::service_ensure == 'present' {
    create_resources('profile::mongodb::role', $roles)
  }
}
