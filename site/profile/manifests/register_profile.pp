#
# used by other modules to register themselves in the system_profile
#
define profile::register_profile (
  $id      = '',
  $order   = 10,
  $content = undef,
) {

  if $content == '' {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment { "10_fragment_profile_${name}":
    target  => '/etc/sysconfig/puppetProfile',
    content => "${body}\n"
  }

}
