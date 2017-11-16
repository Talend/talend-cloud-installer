class profile::mongodb::collections (
  $collections = {},
) {
  if $::profile::mongodb::service_ensure == 'running' or $::profile::mongodb::service_ensure == 'present' {
      create_resources('profile::mongodb::collection', $collections)
  }
}
