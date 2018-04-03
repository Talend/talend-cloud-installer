#
# ECS instance role
#
class role::ecs {
  require ::profile::base
  require ::profile::docker::host
  require ::profile::docker::registry
  require ::profile::docker::ecs_agent
  if hiera('profile::datadog_docker_agent::running'){
    require ::profile::docker::datadog_docker_agent
  }
  require ::profile::common::jsons

  role::register_role { 'ecs': }
}
