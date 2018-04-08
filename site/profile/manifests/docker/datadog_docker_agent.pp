# docker agent for datadog monitoring

class profile::docker::datadog_docker_agent (
  $running = true,
  $image   = 'datadog/docker-dd-agent:12.6.5223',

) {

  require ::profile::docker::host
  # This is value from hiera file just to control installation of the docket for datadog which is ture only for staging and production
  if hiera('profile::datadog_docker_agent::running'){
    $dd_agent_key = hiera('datadog_agent::api_key')
    profile::register_profile { 'datadog_docker_agent': }
    docker::run { 'datadog-docker-agent':
      running      => $running,
      image        => $image,
      volumes      => [
        '/var/run/docker.sock:/var/run/docker.sock:ro',
        '/proc/:/host/proc/:ro',
        '/sys/fs/cgroup:/sys/fs/cgroup:ro'
      ],
      env          => [
        "API_KEY=${dd_agent_key}",
        'LOG_LEVEL=info',
        'DD_PROCESS_AGENT_ENABLED=true'
      ],
      memory_limit => 512m
    }
  }
}
