#
# Sets up a nginx upstream and location for a nexus node
#
define profile::nexus::nginx_location (

  $vhost = undef,
  $total = 1,

) {

  $parts = split($name, '=')
  notice("Total is ${total}")

  nginx::resource::upstream { "${vhost}${parts[0]}":
    ensure  => present,
    members => [$parts[1]],
  }

  if ( $parts[0] != $total ) {
    $next_backend = $parts[0] + 1
    $raw_append = [
      'proxy_intercept_errors on;',
      'recursive_error_pages on;',
      "error_page 401 403 404 500 502 503 = @${vhost}${next_backend};",
    ]
  } else {
    $raw_append = []
  }

  nginx::resource::location { "@${vhost}${parts[0]}":
    vhost      => $vhost,
    proxy      => "http://${vhost}${parts[0]}",
    raw_append => concat(
      $raw_append,
      ['limit_except GET { deny all; }']
    ),
  }

}
