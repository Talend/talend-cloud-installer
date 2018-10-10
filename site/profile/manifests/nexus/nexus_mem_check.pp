# this is class to check nexus memory and restart nexus service if memory is below 500mb and other two instances under elb are in-service

class profile::nexus::nexus_mem_check(
  $nexus_cron_hours = '*'
){
  $nexus_cron_minute= $::cfn_resource_name ? {
    InstanceA => '*/10',
    InstanceB => '3-59/10',
    InstanceC => '6-59/10',
    undef     => 'No Value'
  }
  if hiera('profile::nexus_restart_cron::enable'){
    file { '/usr/local/bin/nexus_mem_check.sh':
      source => 'puppet:///modules/profile/usr/local/bin/nexus_mem_check.sh',
      mode   => '0755',
      owner  => 'root',
      group  => 'root'
    }
    cron{
      'nexus_memory_check':
        ensure  => 'present',
        command => '/usr/local/bin/nexus_mem_check.sh',
        user    => 'root',
        hour    => $nexus_cron_hours,
        minute  => $nexus_cron_minute
    }
  }else{
    notice('nexus restart script / cron not needed for this environment')
  }
}
