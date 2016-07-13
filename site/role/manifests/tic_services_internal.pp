#
# TIC Services role
#
class role::tic_services_internal {

  require profile::tic_services

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
	} ->
	class { 'tic': }

}
