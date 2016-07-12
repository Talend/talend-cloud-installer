#
# TIC Services profile
#
class profile::tic_services {

  require ::profile::base
  require ::profile::java

  # Workaround for DEVOPS-703
  file {
    ['/opt/talend', '/opt/talend/ipaas']:
        ensure => directory,
        before => Package['talend-ipaas-rt-infra']
  }
}
