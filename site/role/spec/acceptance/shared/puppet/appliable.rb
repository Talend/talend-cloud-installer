require 'spec_helper_acceptance'

shared_examples 'puppet::appliable' do |pp|
  it 'should apply with no errors' do
    apply_manifest(
      pp,
      :catch_failures => true,
      :modulepath     => '/tmp/puppet/site:/tmp/puppet/modules',
      :hiera_config   => '/tmp/puppet/hiera.yaml',
      :confdir        => '/tmp/puppet'
    )
  end
end
