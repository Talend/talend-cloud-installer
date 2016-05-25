require 'spec_helper_acceptance'

if hosts_with_role(hosts, 'web').length >= 1
  describe "role::web" do
    context 'TIC web role ' do
      it 'should should run successfully' do

        agent = only_host_with_role(hosts, 'web')

        apply_manifest_on(agent, 'class { "role::web": }', :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules')
        #expect( apply_manifest_on(agent, pp, :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules').exit_code).to be_zero
      end

      # context 'installation of web services' do
      #
      #   describe package('nginx') do
      #     it { is_expected.to be_installed }
      #   end
      #
      #   describe service('nginx') do
      #     it { is_expected.to be_enabled }
      #     it { is_expected.to be_running }
      #   end
      #
      #   describe port(80) do
      #     it { should be_listening }
      #   end
      #
      #   it 'should have java process with correct arguments' do
      #     expect(command('pgrep -a java').stdout).to match /\/opt\/apache-tomcat\/tomcat7\//
      #   end
      #
      #   describe port(8080) do
      #     it { should be_listening }
      #   end

      #end
    end
  end
end
