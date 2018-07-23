#
# ActiveMQ service profile
#
class profile::activemq {

  require ::profile::common::packagecloud_repos
  require ::profile::java
  require ::profile::postgresql

  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs

  profile::register_profile { 'activemq': }

  # prevent postgres provisioning on all the nodes except one: ActiveMQ-A
  # this should be replaced with more sophisticated solution in the future
  $ec2_userdata = pick_default($::ec2_userdata, '')
  if $ec2_userdata =~ /InstanceA/ {
    # The part for AMS password is totaly outdated: https://jira.talendforge.org/browse/DEVOPS-4952

    class { '::activemq': } ->
    class { '::profile::postgresql::provision': }

    contain ::activemq
    contain ::profile::postgresql::provision

    if ($::activemq::service_ensure == 'running') or ($::activemq::service_ensure == 'true') {
        class { '::profile::postgresql::activemq':
          require => Class['::activemq']
        }
    }

  } else {
    contain ::activemq
  }
}
