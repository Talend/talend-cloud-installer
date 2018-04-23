shared_examples 'monitoring::cadvisor' do
  describe service('cadvisor.service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('/usr/bin/curl -v http://127.0.0.1:9500/metrics') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'cadvisor_version_info{' }
  end
end
