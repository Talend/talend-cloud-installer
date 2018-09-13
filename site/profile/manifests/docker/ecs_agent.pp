#
# Installing ECS Agent
#
class profile::docker::ecs_agent (

  $cluster_name = undef,
  $running      = true,
  $image        = 'amazon/amazon-ecs-agent:v1.20.2',

) {

  require ::profile::docker::host

  profile::register_profile { 'docker_ecs_agent': }

  if $cluster_name {
    $cluster_name_real = $cluster_name
  } elsif $::ec2_userdata {
    $userdata_json     = parsejson($::ec2_userdata, {'cloud_formation' => {'ecs_cluster_name' => undef}})
    $cluster_name_real = dig44($userdata_json, ['cloud_formation', 'ecs_cluster_name'], undef)
  } else {
    $cluster_name_real = undef
  }

  if $running {
    firewall {
      '001 forward the metadata address to the ecsagent container':
        table       => 'nat',
        destination => '169.254.170.2',
        dport       => '80',
        proto       => 'tcp',
        chain       => 'PREROUTING',
        jump        => 'DNAT',
        todest      => '127.0.0.1:51679',
        before      => Docker::Run['amazon-ecs-agent'],
        require     => Package['iptables-services'];

      '002 redirect port 80 to 51679 of the metadata address':
        table       => 'nat',
        destination => '169.254.170.2',
        proto       => 'tcp',
        dport       => '80',
        chain       => 'OUTPUT',
        jump        => 'REDIRECT',
        toports     => '51679',
        before      => Docker::Run['amazon-ecs-agent'],
        require     => Package['iptables-services'];
    }
  }

  docker::run { 'amazon-ecs-agent':
    running => $running,
    image   => $image,
    net     => 'host',
    volumes => [
      '/var/run/docker.sock:/var/run/docker.sock',
      '/var/log/ecs/:/log',
      '/var/lib/ecs/data:/data',
      '/sys/fs/cgroup:/sys/fs/cgroup:ro',
      '/var/run/docker/execdriver/native:/var/lib/docker/execdriver/native:ro'
    ],
    env     => [
      'ECS_LOGFILE=/log/ecs-agent.log',
      'ECS_LOGLEVEL=info',
      'ECS_DATADIR=/data',
      'ECS_DISABLE_METRICS=false',
      "ECS_CLUSTER=${cluster_name_real}",
      'ECS_ENABLE_TASK_IAM_ROLE=true',
      'ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true',
      'ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]',
      'ECS_ENABLE_CONTAINER_METADATA=true'
    ]
  }

}
