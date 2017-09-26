class profile::web::nginx_resolvers {

  $create_resolvers_command = 'echo resolver \
  $(awk \'BEGIN{ORS=" "} $1=="nameserver" {print $2}\' /etc/resolv.conf) "valid=5s;" \
  > /etc/nginx-resolvers.conf'

  exec { 'create nginx resolvers.conf':
    command => $create_resolvers_command,
    creates => '/etc/nginx-resolvers.conf',
  }

}
