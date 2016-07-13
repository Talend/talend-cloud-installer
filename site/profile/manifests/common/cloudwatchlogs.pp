#
# Configures cloudwaatch with hiera-defined log files
#
class profile::common::cloudwatchlogs {
  create_resources(
    '::cloudwatchlogs::log',
    hiera_hash('cloudwatchlog_files', {})
  )
}
