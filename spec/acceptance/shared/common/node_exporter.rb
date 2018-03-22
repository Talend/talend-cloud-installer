shared_examples 'profile::common::node_exporter' do
  describe user('node_exporter') do
    it { should exist }
  end

  describe service('node_exporter.service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('/usr/bin/curl -v http://127.0.0.1:9100/metrics') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'node_filesystem_size' }
  end
end
