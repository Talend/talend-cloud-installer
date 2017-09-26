require 'spec_helper'

describe 'role::frontend' do
  it_behaves_like 'profile::base'
  it_behaves_like 'role::defined', 'frontend'

  describe port(8081) do
    it { should be_listening }
  end

  describe command('/usr/bin/wget -O - http://127.0.0.1:8081') do
    its(:stdout) { should include '<title>Talend Integration Cloud</title>' }
  end

  describe port(8009) do
    it { should be_listening }
  end

  describe port(8005) do
    it { should be_listening }
  end

  describe port(8088) do
    it { should be_listening }
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe command('/usr/bin/curl -v http://127.0.0.1:8080/nginx_status') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'Active connections' }
    its(:stdout) { should include 'server accepts handled requests' }
  end

  describe command('/usr/bin/curl -v -I http://127.0.0.1:8088') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'HTTP/1.1 301 Moved Permanently' }
    its(:stdout) { should include 'Location: https://127.0.0.1/' }
  end

  describe command('/usr/bin/ps ax | grep java') do
    its(:stdout) { should include '-Djava.awt.headless=true' }
    its(:stdout) { should include '-Xmx1024m' }
    its(:stdout) { should include '-XX:MaxPermSize=256m' }
    its(:stdout) { should include '-Djava.io.tmpdir=/srv/tomcat/ipaas-srv/temp' }
  end

  describe file('/srv/tomcat/ipaas-srv/webapps/ROOT') do
    it { should be_symlink }
    it { should be_linked_to '/srv/tomcat/ipaas-srv/webapps/ipaas' }
  end

  %w(
  /srv/tomcat/ipaas-srv/webapps/ipaas/config/config.js
  /srv/tomcat/ipaas-srv/conf/jaas-ipaas-services.conf
  /srv/tomcat/ipaas-srv/conf/jaas-ipaas-server.conf
  /srv/tomcat/ipaas-srv/webapps/ipaas-server/META-INF/context.xml
  ).each do |f|
    describe file(f) do
      it { should be_file }
    end
  end

  %w(
  talend-ipaas-web
  talend-ipaas-web-services
  talend-ipaas-web-server
  talend-ipaas-web-memcache-libs).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe file('/srv/tomcat/ipaas-srv/conf/server.xml') do
    its(:content) { should include 'port="8009"' }
    its(:content) { should include 'address="0.0.0.0"' }
    its(:content) { should include 'protocol="AJP/1.3"' }
    its(:content) { should include 'connectionTimeout="20000"' }
    its(:content) { should include 'redirectPort="8443"' }
  end

  describe file('/srv/tomcat/ipaas-srv/conf/server.xml') do
    its(:content) { should include 'port="8081"' }
    its(:content) { should include 'address="0.0.0.0"' }
    its(:content) { should include 'protocol="HTTP/1.1"' }
    its(:content) { should include 'connectionTimeout="20000"' }
    its(:content) { should include 'redirectPort="8443"' }
  end

  describe file('/srv/tomcat/ipaas-srv/webapps/ipaas-server/WEB-INF/web.xml') do
    its(:content) { should include '<secure>false</secure>' }
  end

  describe file('/srv/tomcat/ipaas-srv/webapps/ipaas/WEB-INF/web.xml') do
    its(:content) { should include '<welcome-file>index-min.jsp</welcome-file>' }
  end

  describe service('tomcat-ipaas-srv') do
    it { should be_enabled }
    it { should be_running }
  end

  describe package('jre-jce') do
    it { should_not be_installed }
  end

  describe 'Catalina logs logrotate configuration' do
    subject { file('/etc/logrotate.d/hourly/catalina_out').content }
    it { should include '/srv/tomcat/ipaas-srv/logs/catalina.*' }
    it { should include 'maxsize 250M' }
    it { should include 'copytruncate' }
  end

  describe 'Tomcat logs logrotate configuration' do
    subject { file('/etc/logrotate.d/hourly/tomcat_log').content }
    it { should include '/srv/tomcat/ipaas-srv/logs/*.log' }
    it { should include 'maxsize 250M' }
    it { should include 'copytruncate' }
  end

  %w(
    mongo0.com
    mongo0.net
    mongo0.org
    mongo0.io
    mongo1.com
    mongo1.net
    mongo1.org
    mongo1.io
  ).each do |h|
    describe host(h) do
      it { should be_resolvable.by('hosts') }
    end
  end

  describe file('/srv/tomcat/ipaas-srv/webapps/ipaas/config/config.js') do
    its(:content) { should include "HELP_URL : 'the-help-url'," }
  end

end
