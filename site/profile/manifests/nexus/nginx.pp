#
# Sets up a nginx frontend for the nexus instance
#
# Parameters:
#
#   [*nexus_nodes*]         - Array of nexus nodes
#     for example: [ "10.0.2.12:8081", "10.0.2.23:8081" ]
#
#   [*vhost*]               - nginx vhost name, 'nexus' by default
#
#   [*listen_port*]         - nginx listen_port, '80' by default
#
# Description:
#
#   Nginx is configured with a number of upstreams and locations
#   (one per each nexus node). Every upstream has one nexus node
#   configured. Every location proxies requests to corresponding
#   upsream. Every location except the very last one has a error_page
#   directive in order to fallback to the next location
#   in case if error.
#
#   Example:
#
#   $ cat /etc/nginx/conf.d/nexus1-upstream.conf
#   upstream nexus1{
#     server     10.0.2.12:8081  fail_timeout=10s;
#   }
#
#   $ cat /etc/nginx/conf.d/nexus2-upstream.conf
#   upstream nexus2{
#     server     10.0.2.23:8081  fail_timeout=10s;
#   }
#
#   $ cat /etc/nginx/sites-enabled/nexus.conf
#   server {
#     listen *:80;
#     ...
#     location / {
#       try_files $uri @nexus1;
#     }
#
#     location nexus1 {
#       proxy_pass            http://nexus1;
#       proxy_intercept_errors on;
#       recursive_error_pages on;
#       error_page 401 403 404 500 502 503 = @nexus2;
#     }
#
#     location nexus2 {
#       proxy_pass            http://nexus2;
#     }
#   }
#
#
class profile::nexus::nginx (

  $nexus_nodes = [], # [ "10.0.2.12:8081", "10.0.2.23:8081" ]
  $vhost       = 'nexus',
  $listen_port = 80,

) {

  nginx::resource::vhost { $vhost:
    server_name         => ['_'],
    listen_port         => $listen_port,
    location_custom_cfg => {
      'try_files' => "\$uri @${vhost}1" # <- there is always at least 1 nexus instance
    },
  }

  # [ [" 1", "=10.0.2.12:8081"], [" 2", "=10.0.2.23:8081"] ]
  $_nexus_nodes_pairs = zip(
    prefix(range(1, size($nexus_nodes)), ' '),
    prefix($nexus_nodes, '=')
  )

  # [ "1=10.0.2.12:8081", "2=10.0.2.23:8081" ]
  $_nexus_locations = delete(split(join($_nexus_nodes_pairs, ''), ' '), '')

  profile::nexus::nginx_location { $_nexus_locations:
    vhost => $vhost,
    total => size($_nexus_locations)
  }

}
