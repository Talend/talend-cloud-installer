require 'spec_helper_acceptance'

describe 'role::elasticsearch', :if => fact('puppet_roles').split(',').include?('elasticsearch') do
  it_behaves_like 'puppet::appliable', 'include "role::elasticsearch"'

  context 'when elasticsearch installed and running' do
    describe package('elasticsearch') do
      it { should be_installed }
    end

    describe service('elasticsearch-default') do
      it { should be_running }
    end

    describe command('/usr/share/elasticsearch/bin/plugin --list') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include 'cloud-aws' }
    end

    describe command('/usr/bin/curl "http://localhost:9200/?pretty"') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include '"status" : 200' }
    end
  end
end
