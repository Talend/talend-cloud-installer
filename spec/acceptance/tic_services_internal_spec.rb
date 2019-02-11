require 'spec_helper'

describe 'role::tic_services_internal' do
  it_behaves_like 'profile::base'
  it_behaves_like 'role::defined', 'tic_services_internal'

  describe package('nginx') do
    it { should be_installed.with_version('1.12.1') }
  end

	describe package('talend-ipaas-rt-infra') do
    it { should be_installed }
  end

  describe command('/opt/talend/ipaas/rt-infra/bin/shell "wrapper:install --help"') do
    its(:stdout) { should include 'Install the container as a system service in the OS' }
  end

  describe command('/opt/talend/ipaas/rt-infra/bin/client "list"') do
    its(:stdout) { should include 'Data Transfer Service :: Client' }
    its(:stdout) { should include 'Data Transfer Service :: Common' }
    its(:stdout) { should_not include 'Data Transfer Service :: Core' }
  end

  describe service('karaf') do
    it { should be_enabled }
    it { should be_running.under('systemd') }
  end

  describe port('8180') do
    it { should be_listening }
  end

  describe port('8181') do
    it { should be_listening }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running.under('systemd') }
  end

  describe 'Nginx configuration' do
    subject { file('/etc/nginx/nginx.conf').content }
    it { should match(/server_tokens.*off;/) }
    it { should match(/keepalive_timeout.*5 5;/) }
    it { should match(/client_body_buffer_size.*128k;/) }
    it { should match(/client_max_body_size.*500M;/) }
    it { should match(/proxy_connect_timeout.*3600;/) }
    it { should match(/proxy_read_timeout.*3600;/) }
    it { should match(/proxy_send_timeout.*3600;/) }
  end

  describe command('/usr/bin/curl -v http://127.0.0.1:8181/nginx_status') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include 'Active connections' }
    its(:stdout) { should include 'server accepts handled requests' }
  end

  describe command('/usr/bin/curl http://localhost:8181/services') do
    its(:stdout) { should include 'Service list' }
  end

  describe command('/usr/bin/curl http://localhost:8180/services') do
    its(:stdout) { should include 'Service list' }
  end

  describe 'Service configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/karaf-wrapper.conf').content }
    it { should match /wrapper.jvm_kill.delay\s*=\s*5/ }
    it { should match /wrapper.java.additional.10\s*=\s*-XX:MaxMetaspaceSize=256m/ }
    it { should match /wrapper.java.additional.11\s*=\s*-Dcom.sun.management.jmxremote.port=7199/ }
    it { should match /wrapper.java.additional.12\s*=\s*-Dcom.sun.management.jmxremote.authenticate=false/ }
    it { should match /wrapper.java.additional.13\s*=\s*-Dcom.sun.management.jmxremote.ssl=false/ }
    it { should match /wrapper.java.maxmemory\s*=\s*1024/ }
    it { should match /wrapper.disable_restarts\s*=\s*true/ }
  end

  describe 'Artifact Manager Service configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/org.talend.ipaas.rt.am.service.cfg').content }
    it { should include 'nexus_urls=http://10.0.2.12:8081/nexus,http://10.0.2.23:8081/nexus' }
  end

  describe 'Custom Resources Service configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/org.talend.ipaas.rt.cr.service.cfg').content }
    it { should include 'bucket.name = mytestbucket' }
    it { should include 'object.key.prefix = mytestprefix' }
  end

  describe 'Account Management Service configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/org.talend.ipaas.rt.ams.core.cfg').content }
    it { should include 'password.reset.url.template=https://my-password-reset-host.com' }
  end

  describe 'Additional Java Packages' do
    subject { package('jre-jce') }
    it { should be_installed }
  end

  describe package('jre1.8') do
    it { should be_installed.with_version('1.8.0_181-fcs') }
  end

  describe 'CMS configuration' do
    subject { file('/opt/talend/ipaas/rt-infra/etc/org.talend.ipaas.rt.cms.config.cfg').content }
    it { should include 'karaf/org.ops4j.pax.url.mvn/org.ops4j.pax.url.mvn.repositories=http://{{username}}:{{password}}@10.0.2.12' }
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

  describe file('/var/tmp/init_configuration_service.json') do
    its(:content) { should include 'nodeman.subnet.default.us-east-1' }
    its(:content) { should include 'nodeman.subnets.failover.us-east-1' }
    its(:content) { should include '"value": "subnet-aaaaaaaa"' }
    its(:content) { should include '"value": ["subnet-bbbbbbbb", "subnet-cccccccc"]' }
    its(:content) { should include '"value": "my-branch"' }
  end

  %w(
    nexus0
    nexus1
  ).each do |h|
    describe host(h) do
      it { should be_resolvable.by('hosts') }
    end
  end

end
