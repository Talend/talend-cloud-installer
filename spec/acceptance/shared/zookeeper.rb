shared_examples 'profile::zookeeper' do

  it_behaves_like 'profile::defined', 'zookeeper'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /opt/apache-tomcat/logs/catalina.out
    /var/log/zookeeper/zookeeper.log
  )

  describe command('/usr/bin/sleep 120') do
    its(:exit_status) { should eq 0 }
  end

  describe port(2181) do
    it { should be_listening }
  end

  describe command('/usr/bin/curl http://127.0.0.1:8080/exhibitor/v1/cluster/state') do
    its(:stdout) { should match /"description":".*?"/ }
  end

  describe package('jre-jce') do
    it { should_not be_installed }
  end

  describe 'Exhibitor package' do
    subject { command('/bin/rpm -q netflix-exhibitor-tomcat') }
    its(:stdout) { should include 'netflix-exhibitor-tomcat-1.7.1-1.x86_64' }
  end

  describe file('/etc/rc.d/init.d/zookeeper') do
    it { should_not exist }
  end

  describe file('/home/tomcat') do
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
  end

  describe file('/etc/init.d/zookeeper') do
    it { should_not exist }
  end

  describe service('tomcat-exhibitor') do
    it { should be_running.under('systemd') }
  end

  describe command('/usr/bin/curl -v http://127.0.0.1:8080/exhibitor/v1/config/get-state') do
    its(:stdout) { should include '"clientPort":2181' }
    its(:stdout) { should include '"connectPort":2888' }
    its(:stdout) { should include '"electionPort":3888' }
  end

  # https://zookeeper.apache.org/doc/r3.1.2/zookeeperAdmin.html#sc_monitoring
  describe command('echo ruok | /bin/nc 127.0.0.1 2181') do
    its(:stdout) { should eq 'imok' }
  end
end
