class profile::mongodb::collections (

  $db_address  = undef,
  $collections = {},

) {

  if $profile::mongodb::service_ensure == 'running' {
    $instanceLogicalId = pick($::cfn_resource_name, $::ec2_userdata, '')
    if $instanceLogicalId =~ /InstanceA/ {
      create_resources('profile::mongodb::collection', $collections)
    }
  }

}
