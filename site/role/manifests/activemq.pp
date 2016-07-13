#
# ActiveMQ service role
#
class role::activemq {

  include ::profile::base
  include ::profile::activemq

  role::register_role { 'activemq': }

}
