#
# Test Instance of the testlauncher stack
#
class role::test_launcher {

  require ::profile::base
  require ::profile::docker::host
  require ::profile::docker::registry
  require ::profile::test_launcher
  role::register_role { 'test_launcher': }


}
