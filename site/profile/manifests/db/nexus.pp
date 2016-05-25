# Setting up the single nexus instance
#
class profile::db::nexus (

  $nexus_root = '/srv',

) {

  include java

  ensure_packages(['wget'])

  class{ '::nexus':
    version    => '2.8.0',
    revision   => '05',
    nexus_root => $nexus_root, # All directories and files will be relative to this
  }

  Class['::java'] ->
  Class['::nexus']

}
