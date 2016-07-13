#
# Waits for the elasticsearch service to start
#
class profile::elasticsearch::wait {

  require ::profile::elasticsearch::setup
  require ::profile::common::packages

  exec { 'waiting for Elasticsearch to start':
    command => '/usr/bin/wget --spider --tries 15 --retry-connrefused "http://localhost:9200/?pretty"'
  }

}
