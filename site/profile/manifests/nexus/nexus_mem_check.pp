# this is class to check nexus memory and restart nexus service if memory is below 500mb and other two instances under elb are in-service

class profile::nexus::nexus_mem_check(
  $nexus_cron_hours = '*',
  $nexus_cron_minute = '*/10',
  $ec2_userdata = pick_default($::ec2_userdata, '')
){
  if $ec2_userdata =~ /InstanceA/ {
    $nexus_cron_minute = '0,10,20,30,40,50'
  }elsif $ec2_userdata =~ /InstanceB/ {
    $nexus_cron_minute = '3,13,23,33,43,53'
  }else{
    $nexus_cron_minute = '6,16,26,36,46,56'
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
