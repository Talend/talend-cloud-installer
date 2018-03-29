#
# Installing Datadog docker agent
#
class profile::docker::datadog_docker_agent (

  $running = true,
  $image   = 'datadog/docker-dd-agent:12.6.5223'

) {

  require ::profile::docker::host
  profile::register_profile { 'datadog_docker_agent': }

  docker::run { 'datadog-docker-agent':
    running => $running,
    image   => $image,
    volumes => [
      '/var/run/docker.sock:/var/run/docker.sock:ro',
      '/proc/:/host/proc/:ro',
      '/cgroup/:/host/sys/fs/cgroup:ro'
    ],
    env     => [
      'LOG_LEVEL=debug',
      API_KEY=$datadog::agent::api_key
    ]
  }

}


