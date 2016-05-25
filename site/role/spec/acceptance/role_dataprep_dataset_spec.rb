require 'spec_helper_acceptance'


if hosts_with_role(hosts, 'dataprepdataset').length >= 1
  describe "role::dataprepdataset" do

    context 'role::dataprep_dataset install' do

      it 'should provision role::dataprep_dataset' do
        pp = <<-EOS
        include 'role::dataprep_dataset'
        EOS

        agent = only_host_with_role(hosts, 'dataprepdataset')

        apply_manifest_on(agent, pp, :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules')
      end

      it 'should have java process with correct arguments' do
        expect(command('pgrep -a java').stdout).to match /\/opt\/talend\/dataprep\//
      end

    end
  end
end