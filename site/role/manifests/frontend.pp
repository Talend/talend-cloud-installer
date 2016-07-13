#
# TIC Frontend role
#
class role::frontend {

  include ::profile::base

  class { 'tic::globals':
    role                    => 'frontend',
    java_xmx                => 1024,
    web_enable_test_context => false,
    web_use_ssl             => true,
    cms_node                => 'cmsnode'
  } ->
  class { 'tic': }

}
