#
# common logrotate rules for instances
#
class profile::common::logrotate {
  file { '/etc/logrotate.d/syslog':
    ensure => file,
    source => 'puppet:///modules/profile/etc/logrotate.d/syslog',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }
}
