class profile::test_launcher (
  $tmc_pswseed   = undef,
  $tmc_url       = undef,
  $scim_url      = undef,
  $login_url     = undef,
  $report_bucket = undef,

) {

  file { '/opt/talend/':
    ensure => 'directory',
  }

  file { '/opt/talend/tmc/':
    ensure => 'directory',
  }
  file { '/opt/talend/tmc/tests_variables.sh':
    content => "#!/bin/bash
export TMC_URL=${tmc_url}
export SCIM_URL=${scim_url}
export LOGIN_URL=${login_url}
export PSWSEED=${tmc_pswseed}
export REPORT_BUCKET=${report_bucket}
"
  }

}