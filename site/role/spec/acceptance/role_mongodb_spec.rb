require 'spec_helper_acceptance'

if hosts_with_role(hosts, 'mongodb').length >= 1
  describe "role::mongodb" do
    context 'TIC mongodb role ' do
      it 'should should run successfully' do

        agent = only_host_with_role(hosts, 'mongodb')

        apply_manifest_on(agent, 'class { "role::mongodb": }', :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules')
        #expect( apply_manifest_on(agent, pp, :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules').exit_code).to be_zero
      end

      context 'installation of jmongodb services' do

        describe package('mongodb') do
          it { is_expected.to be_installed }
        end

        describe service('mongod') do
          it { is_expected.to be_enabled }
          it { is_expected.to be_running }
        end

        describe port(27017) do
          it { should be_listening }
        end

      end
    end
  end
end
