#
# Finalizes rsyslog resources for puppetProfile and puppetRole files
#
class profile::common::rsyslog {
  include ::rsyslog
  class { '::rsyslog::client':
    log_remote    => false,
    log_local     => false,
    log_templates => [
      {
        name     => 'CloudwatchAgent',
        template => '%TIMESTAMP% %msg%',
      },
      {
        name     => 'CloudwatchAgentEOL',
        template => '%TIMESTAMP% %msg%\n',
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
