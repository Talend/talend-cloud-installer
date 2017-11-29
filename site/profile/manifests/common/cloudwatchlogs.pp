#
# Configures cloudwatch with hiera-defined log files
#
class profile::common::cloudwatchlogs (
  $include = true,
  $recursive = true
) {
  if $include {
    if $recursive {
      $logs_to_export = hiera_hash('cloudwatchlog_files', {})
    } else {
      $logs_to_export = hiera('cloudwatchlog_files', {})
    }
    create_resources('::cloudwatchlogs::log', $logs_to_export)
  }
}
