shared_examples 'profile::nexus' do

  it_behaves_like 'profile::defined', 'nexus'
  it_behaves_like 'profile::common::packages'
  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /srv/sonatype-work/nexus/logs/nexus.log
    /srv/sonatype-work/nexus/logs/request.log
  )

  describe service('nexus') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe port(8081) do
    it { should be_listening }
  end

  describe 'nexus user deployment should be removed' do
    describe file('/srv/sonatype-work/nexus/conf/security.xml') do
      it { should be_file }
      its(:content) { should_not include '<id>deployment</id>' }
    end
  end

  describe 'anonymous access should be disabled' do
    describe file('/srv/sonatype-work/nexus/conf/security-configuration.xml') do
      it { should be_file }
      its(:content) { should include '<anonymousAccessEnabled>false</anonymousAccessEnabled>' }
    end
  end

  describe 'admin user should have its password updated' do
    describe command('/usr/bin/curl -v -f -X GET -u admin:randompassword http://localhost:8081/nexus/service/local/users/admin 2>&1') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include 'HTTP/1.1 200 OK' }
      its(:stdout) { should include '<userId>admin</userId>' }
    end
  end

end
