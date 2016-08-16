#
# TIC Services role
#
class role::tic_services_internal {

  require ::profile::base
  require ::profile::tic_services
  require ::profile::amazon_ses_smtp

  role::register_role { 'tic_services_internal': }

}
