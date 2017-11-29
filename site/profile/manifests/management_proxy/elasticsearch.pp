define profile::management_proxy::elasticsearch (

  $nginx_vhost              = undef,
  $nginx_location           = '',
  $nginx_location_priority  = 500,
  $elasticsearch_host       = undef,
  $elasticsearch_url_scheme = 'https',
  $elasticsearch_url        = undef,
  $auth_realm               = 'Elasticsearch',
  $auth_username            = undef,
  $auth_password            = undef,

) {

  if $elasticsearch_url {
    $_elasticsearch_url = $elasticsearch_url
  } else {
    $_elasticsearch_url = "${elasticsearch_url_scheme}://${elasticsearch_host}/"
  }

  if $auth_username and $auth_password {
    $htpasswd_file = '/etc/nginx/.htpasswd'

    $password = pw_hash($auth_password, 'SHA-512', fqdn_rand_string(10))
    file_line { "${name}:basic auth line":
      ensure  => present,
      path    => $htpasswd_file,
      line    => "${auth_username}:${password}",
      match   => "^${auth_username}\\:",
      replace => false,
    }

    $auth_basic           = $auth_realm
    $auth_basic_user_file = $htpasswd_file
  } else {
    $auth_basic           = undef
    $auth_basic_user_file = undef
  }

  nginx::resource::location { "${name}:nginx location":
    ensure               => present,
    vhost                => $nginx_vhost,
    location             => "~ ${nginx_location}/(.*)",
    priority             => $nginx_location_priority,
    auth_basic           => $auth_basic,
    auth_basic_user_file => $auth_basic_user_file,
    proxy                => '$proxy_url$1$is_args$args',
    raw_append           => ['proxy_pass_request_headers off;'],
    raw_prepend          => [
      'include /etc/nginx-resolvers.conf;',
      "set \$proxy_url ${_elasticsearch_url};"
    ],
  }
}
