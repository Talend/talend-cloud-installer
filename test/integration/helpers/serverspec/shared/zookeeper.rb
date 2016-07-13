shared_examples 'profile::zookeeper' do

  it_behaves_like 'profile::defined', 'zookeeper'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /opt/tomcat/logs/catalina.out
  )

  describe port(2181) do
    it { should be_listening }
  end

  describe command('/usr/bin/wget -O - http://localhost:8080/exhibitor/exhibitor/v1/cluster/state') do
    its(:stdout) { should include '"description":"serving"' }
  end

end
