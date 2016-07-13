#
# Apache Syncope service role
#
class role::syncope {

  include ::profile::base
  include ::profile::web::syncope

  role::register_role { 'syncope': }

}
