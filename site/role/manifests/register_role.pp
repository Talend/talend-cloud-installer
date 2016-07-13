#
# used by other modules to register themselves in the system_role
#
define role::register_role(

  $id      = '',
  $order   = 10,
  $content = undef,

) {

  if $content == '' {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment { "10_fragment_role_${name}":
    target  => '/etc/sysconfig/puppetRole',
    content => "${body}\n"
  }

}
