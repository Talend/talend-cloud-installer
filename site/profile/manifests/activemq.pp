#
# ActiveMQ service profile
#
class profile::activemq(
  $with_postgresql_optimizations = true,
  $network_broker_endpoint = undef,
){

  require ::profile::common::packagecloud_repos
  require ::profile::java
  require ::profile::postgresql

  include ::profile::common::concat
  include ::profile::common::cloudwatchlogs

  class { '::monitoring::jmx_exporter':
    before => Class['::activemq'],
  }

  if empty($network_broker_endpoint) {
    $network_broker_uri = undef
  } else {
    $network_broker_uri = "static:(tcp://${network_broker_endpoint}:61617)"
  }

  profile::register_profile { 'activemq': }

  file { 'activemq sysctl conf':
    ensure => file,
    path   => '/etc/sysctl.d/activemq_jetty.conf',
    source => 'puppet:///modules/profile/etc/sysctl.d/activemq_jetty.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    before => Class['::activemq'],
    notify => Exec['activemq sysctl apply']
  }

  exec { 'activemq sysctl apply':
    path        => '/usr/bin:/usr/sbin/:/bin:/sbin',
    command     => 'sysctl --system',
    refreshonly => true
  }

  # prevent postgres provisioning on all the nodes except one: ActiveMQ-A
  # this should be replaced with more sophisticated solution in the future
  $ec2_userdata = pick_default($::ec2_userdata, '')
  if $ec2_userdata =~ /InstanceA/ {
    # The part for AMS password is totaly outdated: https://jira.talendforge.org/browse/DEVOPS-4952

    class { '::activemq':
      network_connector_uri => $network_broker_uri,
    } ->
    class { '::profile::postgresql::provision': }

    contain ::activemq
    contain ::profile::postgresql::provision

    if (( $::activemq::persistence == 'postgres')
      and (($::activemq::service_ensure == 'running')
        or ($::activemq::service_ensure == 'true'))) {
      if (str2bool($with_postgresql_optimizations)) {
        class { '::profile::postgresql::activemq':
          require => Class['::activemq']
        }
      } else {
        notify{'Database optimizations explicitely ignored':
          require => Class['::activemq']
        }
      }
    }
  } else {
    class { '::activemq':
      network_connector_uri => $network_broker_uri,
    }
  }
}
