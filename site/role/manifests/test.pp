#
# Test Instance of the Debug stack
#
class role::test {

  require ::profile::java
  require ::profile::base
  require ::profile::docker::host
  require ::profile::docker::registry
  require ::profile::web::nginx
  require ::profile::web::nginx_resolvers
  require ::pip

  role::register_role { 'test': }

  pip::install { 'invoke': }

  file { '/opt/talend/ipaas/rt-integration-test/config.ini':
    content => "[ipaas-rt-test]
nexus=${::nexus_host}
infra=${::services_internal_host}
iam_scim=${::tpsvc_iam_scim_back_url}
"
  }

}
