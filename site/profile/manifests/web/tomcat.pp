# -*- mode: puppet -*-
# vi: set ft=puppet
#
# === Authors
# Andreas Heumaier <andreas.heumaier@nordcloud.com>
#
class profile::web::tomcat (){

  unless defined(Package['epel-release']){
    package{  'epel-release':
      ensure  => 'installed',
    }
  }
  package{  'ruby-augeas':
    ensure  => 'installed',
    require => Package['epel-release']
  }

  java::oracle { 'jdk8' :
    ensure  => 'present',
    version => '8',
    java_se => 'jre',
  } ->

  tomcat::instance { 'tomcat7':
    install_from_source => true,
    source_url          => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.69/bin/apache-tomcat-7.0.69.tar.gz',
    manage_user         => true,
    manage_group        => true,
    user                => 'tomcat',
    group               => 'tomcat',
    catalina_base       => '/opt/apache-tomcat/tomcat7',
    java_home           => '/opt/jdk-7',
  } ->
  tomcat::service { 'tomcat7':
    catalina_base => '/opt/apache-tomcat/tomcat7',
    use_init      => false,
  }

  profile::register_profile{ 'tomcat': }


}
