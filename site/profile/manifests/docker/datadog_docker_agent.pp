# docker agent for datadog monitoring

class profile::docker::datadog_docker_agent (
  $running = true,
  $image   = 'datadog/docker-dd-agent:12.6.5223',
  $dd_agent_key = hiera('datadog_agent::api_key')

) {

  require ::profile::docker::host
  profile::register_profile { 'datadog_docker_agent': }

  docker::run { 'datadog-docker-agent':
    running => $running,
    image   => $image,
    volumes => [
      '/var/run/docker.sock:/var/run/docker.sock:ro',
      '/proc/:/host/proc/:ro',
      '/sys/fs/cgroup:/sys/fs/cgroup:ro'
    ],
    env     => [
      "API_KEY=${dd_agent_key}",
      'LOG_LEVEL=info',
      'DD_PROCESS_AGENT_ENABLED=true'
    ]
  }
  file { "${datadog_agent::params::conf_dir}/docker_daemon.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    source  => 'puppet:///modules/profile/docker_daemon.yaml',
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
  exec { 'dd-agent docker membership':
    command => '/usr/sbin/usermod -aG docker dd-agent',
    require => User['dd-agent']
  }
  

}
