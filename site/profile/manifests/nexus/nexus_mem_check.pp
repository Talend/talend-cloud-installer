# this is class to check nexus memory and restart nexus service if memory is below 500mb and other two instances under elb are in-service

class profile::nexus::nexus_mem_check(
  $nexus_cron_hours = '*',
  $nexus_cron_minute = '*/10'
){
  file { '/usr/local/bin/nexus_mem_check.sh':
    source  => 'puppet:///modules/profile/usr/local/bin/nexus_mem_check.sh',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package[awscli];
  }
  if hiera('profile::nexus_restart_cron::enable'){
    cron{
      'nexus_memory_check':
        ensure  => 'present',
        command => '/usr/local/bin/nexus_mem_check.sh',
        user    => 'root',
        hour    => $nexus_cron_hours,
        minute  => $nexus_cron_minute
    }
  }
}
