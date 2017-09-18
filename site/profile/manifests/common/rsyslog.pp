#
# Finalizes rsyslog resources for puppetProfile and puppetRole files
#
class profile::common::rsyslog {
  include ::rsyslog
  $rsyslog_tpl_day = '%TIMESTAMP:::date-year%-%TIMESTAMP:::date-month%-%TIMESTAMP:::date-day%'
  $rsyslog_tpl_hour = '%TIMESTAMP:::date-hour%:%TIMESTAMP:::date-minute%:%TIMESTAMP:::date-second%'
  class { '::rsyslog::client':
    log_remote    => false,
    log_local     => false,
    log_templates => [
      {
        name     => 'CloudwatchAgent',
        template => "${rsyslog_tpl_day} ${rsyslog_tpl_hour} %msg%",
      },
      {
        name     => 'CloudwatchAgentEOL',
        template => "${rsyslog_tpl_day} ${rsyslog_tpl_hour} %msg%\\n",
      },
    ],
  }
  file { '/etc/rsyslog.d/99_local_logs.conf':
    ensure => file,
    source => 'puppet:///modules/profile/etc/rsyslog.d/local_logs.conf',
    mode   => '0600',
    notify => Class['rsyslog::service'],
  }
}
