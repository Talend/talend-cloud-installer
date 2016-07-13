# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::web::nginx {

  require ::nginx

  include ::profile::common::concat

  profile::register_profile{ 'nginx': }

  if $::osfamily == 'RedHat'{
    selinux::boolean{ 'httpd_can_network_connect':
      ensure => 'on',
    }
    selinux::boolean{ 'httpd_setrlimit':
      ensure => 'on',
    }
  }

  # configuring nginx applications from hiera
  $nginx_vhosts = hiera_hash('nginx::resource::vhosts', {})
  create_resources('nginx::resource::vhost',$nginx_vhosts)

  $nginx_locations = hiera_hash('nginx::resource::locations', {})
  create_resources('nginx::resource::location',$nginx_locations)

  $nginx_upstreams = hiera_hash('nginx::resource::upstreams', {})
  create_resources('nginx::resource::upstream',$nginx_upstreams)

}
