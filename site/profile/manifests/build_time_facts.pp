# build_time_facts
#
# Creates facts during building of AMI
#
# @param facts_hash [Hash] Example: $facts_hash = { 'ipaas_rt_infra_build_version' => $::tic_services_version }
#
class profile::build_time_facts($facts_hash) {

  validate_hash($facts_hash)

  file {
    '/etc/facter/facts.d/build_time_facts.json':
      content => inline_template('<%= Hash[@facts_hash.sort_by { |key, val| key }].to_json %>'),
      require => File['/etc/facter/facts.d'];
  }
}
