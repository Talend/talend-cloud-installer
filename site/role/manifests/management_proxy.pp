#
#
class role::management_proxy(

  $elasticsearch = {},

) {

  require ::profile::base
  require ::profile::web::nginx
  require ::profile::web::nginx_resolvers

  nginx::resource::vhost { 'es-sys':
    server_name          => ['_'],
    listen_port          => '8080',
    use_default_location => false,
  }

  file { '/etc/nginx/.htpasswd':
    ensure => present,
  }

  create_resources(
    '::profile::management_proxy::elasticsearch',
    $elasticsearch,
    {
      nginx_vhost => 'es-sys',
    }
  )

}
