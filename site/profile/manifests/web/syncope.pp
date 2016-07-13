# tomcat syncope  service profile
#
class profile::web::syncope {

  require ::profile::common::packagecloud_repos
  require ::profile::java
  require ::profile::postgresql

  include ::profile::common::concat

  profile::register_profile { 'syncope': }

  contain ::syncope

}
