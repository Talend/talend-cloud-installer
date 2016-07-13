#
# Elasticsearch service role
#
class role::elasticsearch {

  include ::profile::base
  include ::profile::elasticsearch

  role::register_role { 'elasticsearch': }

}
