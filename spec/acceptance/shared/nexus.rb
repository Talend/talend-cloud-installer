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

  describe file('/srv') do
    it do
      should be_mounted.with(
        :type    => 'xfs',
        :options => {
          :rw         => true,
          :noatime    => true,
          :nodiratime => true
        }
      )
    end
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
    %w(8081 80).each do |port_number|
      describe "requesting admin user from nexus on port #{port_number}" do
        subject { command("/usr/bin/curl -v -f -X GET -u admin:mypassword http://localhost:#{port_number}/nexus/service/local/users/admin 2>&1") }
        its(:exit_status) { should eq 0 }
        its(:stdout) { should include 'HTTP/1.1 200 OK' }
        its(:stdout) { should include '<userId>admin</userId>' }
      end

    end
  end

  %w(0 1 2).each do |num|
    describe "requesting admin user from nexus on port 80 and with legacy URI #{num}" do
      subject { command("/usr/bin/curl -v -f -X GET -u admin:mypassword http://localhost:80/nexus#{num}/service/local/users/admin 2>&1") }
      its(:exit_status) { should eq 0 }
      its(:stdout) { should include 'HTTP/1.1 200 OK' }
      its(:stdout) { should include '<userId>admin</userId>' }
    end
  end

  describe "testing healthcheck" do
    subject { command("/usr/bin/curl -v -f -X GET http://localhost:80/health 2>&1") }
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'HTTP/1.1 200 OK' }
    its(:stdout) { should include 'pong' }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe file('/etc/nginx/conf.d/nexus1-upstream.conf') do
    it { should be_file }
    its(:content) { should include 'upstream nexus1' }
  end

  describe file('/etc/nginx/sites-enabled/nexus.conf') do
    its(:content) { should include 'location @nexus1' }
  end

  describe 'Nginx configuration' do
    subject { file('/etc/nginx/nginx.conf').content }
    it { should match(/server_tokens.*off;/) }
    it { should match(/keepalive_timeout.*5 5;/) }
    it { should match(/client_body_buffer_size.*128k;/) }
    it { should match(/client_max_body_size.*500M;/) }
    it { should match(/proxy_connect_timeout.*10;/) }
    it { should match(/proxy_read_timeout.*60;/) }
    it { should match(/proxy_send_timeout.*60;/) }
  end

  describe package('jre-jce') do
    it { should_not be_installed }
  end

  describe file('/srv/nexus/bin/jsw/conf/wrapper.conf') do
    its(:content) { should include 'wrapper.java.additional.3=-Djava.util.prefs.userRoot=/srv/nexus' }
  end

  describe file('/usr/local/bin/nexus_mem_check.sh') do
    it { should be_file }
  end

  describe command ('/usr/bin/sudo crontab -l')do
    its(:stdout) {should include '/usr/local/bin/nexus_mem_check.sh' }
  end

  describe file('/srv/puppet_nexus_work_managed_dir_chown.flag') do
    it { should be_file }
  end
end
