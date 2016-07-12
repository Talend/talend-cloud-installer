#
# TIC Services role
#
class role::tic_services_external {

  require profile::tic_services

  $common_features = [
    '(aries-blueprint',
    'bundle',
    'config',
    'deployer',
    'diagnostic',
    'feature',
    'instance',
    'jaas',
    'kar',
    'log',
    'management',
    'package',
    'service',
    'shell',
    'shell-compat',
    'ssh',
    'system',
    'wrap)',
    'camel',
    'tipaas-crypto-service-client',
    'tipaas-artifact-manager-client-runtime',
    'tipaas-bookkeeper-client',
    'tipaas-account-manager-client',
    'tipaas-scheduler-client',
    'tipaas-dispatcher-client',
    'tipaas-plan-executor-client',
    'tipaas-flow-manager-client',
    'tipaas-healthcheck-service-core',
    'tipaas-container-management-service-client',
    'tipaas-configuration-service-client',
    'tipaas-webhooks-client',
    'tipaas-notification-client',
    'tipaas-notification-subscription-client',
    'tipaas-data-transfer-service-client',
  ]

  $additional_features = [
    'tipaas-zookeeper-server',
    'tipaas-crypto-service-core',
    'tipaas-bookkeeper-service',
    'tipaas-data-transfer-service-core',
    'tipaas-artifact-manager-service',
    'tipaas-account-manager-service',
    'tipaas-dispatcher-core',
    'tipaas-scheduler',
    'tipaas-plan-executor-service',
    'tipaas-flow-manager-service',
    'tipaas-container-management-service',
    'tipaas-pairing-service',
    'tipaas-configuration-service-core',
    'tipaas-schema-discovery-service-core',
    'tesb-el-elasticsearch',
    'tesb-el-server',
    'tesb-el-collector-jms',
    'tipaas-webhooks-service',
    'tipaas-trial-registration-service',
    'tipaas-plan-executor-service',
    'tipaas-custom-resources-service',
    'tipaas-notification-subscription-service',
    'tipaas-notification-manager',
    'tipaas-notification-server',
    'tipaas-notification-sendgrid-webhook-service'
  ]


  class { 'tic::globals':
    role                               => 'services',
    hiera_dts_s3_bucket_test_data      => 'us-east-1-rd-tipaas-dts-test-talend-com',
    hiera_dts_s3_bucket_rejected_data  => 'us-east-1-rd-tipaas-dts-rejected-talend-com',
    hiera_dts_s3_bucket_logs_data      => 'us-east-1-rd-tipaas-dts-logs-talend-com',
    hiera_dts_s3_bucket_downloads_data => 'us-east-1-rd-tipaas-dts-downloads-talend-com',
    karaf_service_ensure               => running,
    java_xmx                           => 1024,
    web_enable_test_context            => false,
    web_use_ssl                        => true,
    cms_node                           => 'cmsnode',
    java_home                          => '/usr/java/jre1.8.0_60',

    # WIP Integration settings
    hiera_karaf_base_features_install        => $common_features,
    hiera_karaf_additional_features_install  => $additional_features,
    default_activemq_nodes                   => $::activemq_nodes,
    hiera_zookeeper_nodes                    => $::zookeeper_nodes,
    hiera_postgres_db_host                   => $::postgres_nodes,
    default_nexus_nodes                      => $::nexus_nodes,
    hiera_elasticsearch_host                 => $::elasticsearch_nodes,
    hiera_mongo_nodes                        => [$::mongodb_nodes],
    hiera_webhooks_redis_host                => $::redis_nodes,
    # hiera_ams_syncope_host                   => $::syncope_nodes

  } ->

  class { 'tic': }

}

