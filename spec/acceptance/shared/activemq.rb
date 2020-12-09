shared_examples 'profile::activemq' do

  it_behaves_like 'profile::defined', 'activemq'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::cloudwatchlog_files', %w(/opt/activemq/data/activemq.log)

  describe 'Verifying activemq sysctl conf' do
    describe file('/etc/sysctl.d/activemq_jetty.conf') do
      it { should be_file }
      its(:content) { should include '# File managed by Puppet, do not edit manually' }
    end
    describe command('/sbin/sysctl -a') do
      its(:stdout) { should include 'net.core.rmem_max = 16777216' }
      its(:stdout) { should include 'net.core.wmem_max = 16777216' }
      its(:stdout) { should include 'net.ipv4.tcp_rmem = 4096	87380	16777216' }
      its(:stdout) { should include 'net.ipv4.tcp_wmem = 4096	16384	16777216' }
      its(:stdout) { should include 'net.core.somaxconn = 4096' }
      its(:stdout) { should include 'net.core.netdev_max_backlog = 16384' }
      its(:stdout) { should include 'net.ipv4.tcp_max_syn_backlog = 8192' }
      its(:stdout) { should include 'net.ipv4.tcp_syncookies = 1' }
      its(:stdout) { should include 'net.ipv4.ip_local_port_range = 10000	65535' }
      its(:stdout) { should include 'net.ipv4.tcp_tw_recycle = 1' }
    end
  end

  describe package('activemq') do
    it { should be_installed.with_version('5.15.13-3') }
  end

	describe service('activemq') do
		it { should be_enabled }
		it { should be_running }
	end

	describe port(8161) do
		it { should be_listening }
	end

	describe port(5432) do
		it { should be_listening }
	end

  describe package('jre-jce') do
    it { should_not be_installed }
  end

  describe package('ptic-postgresql-schemes') do
    it { should_not be_installed }
  end

  describe package('postgresql11') do
    it { should be_installed }
  end

  describe file('/opt/activemq/conf/activemq.xml') do
    its(:content) { should include '<queue physicalName="ipaas.talend.dispatcher.response.queue"/>' }
    its(:content) { should include 'tcp://0.0.0.0:61616?maximumConnections=5000&amp;wireFormat.maxFrameSize=104857600' }
    its(:content) { should include 'http://0.0.0.0:8080?jetty.config=/opt/activemq/conf/jetty-server.xml&amp;wireFormat.maxFrameSize=52428800' }
    its(:content) { should include '<networkConnector name="connector-bridge"  uri="static:(tcp://activemq-broker-new.localdomain:61617)" />' }
  end

  describe file('/opt/activemq/conf/jetty-server.xml') do
    its(:content) { should include '<Set name="minThreads">10</Set>' }
    its(:content) { should include '<Set name="maxThreads">3000</Set>' }
  end

  describe 'ActiveMQ optimization version table' do
    subject { command('PGPASSWORD=mypassword /usr/bin/psql -q -h localhost -U activemq -d activemq -c "select MAX(version) from tmp_activemq_optimizations where filename = \'postgresql_optimizations.sql\';"') }
    its(:stdout) { should include '0.1' }
  end

  describe 'get ActiveMQ optimizations from activemq_msgs' do
    subject { command('PGPASSWORD=mypassword /usr/bin/psql -q -h localhost -U activemq -d activemq -c \'\\d+ activemq_msgs\' -o /tmp/activemq_msgs.struct') }
    its(:exit_status) { should eq 0 }
  end

  describe 'get ActiveMQ optimizations from activemq_acks' do
    subject { command('PGPASSWORD=mypassword /usr/bin/psql -q -h localhost -U activemq -d activemq -c \'\\d+ activemq_acks\' -o /tmp/activemq_acks.struct') }
    its(:exit_status) { should eq 0 }
  end

  describe 'verifying ActiveMQ optimizations for activemq_msgs' do
    subject { file('/tmp/activemq_msgs.struct') }
    its(:content) { should include 'tmp_activemq_msgs_p_desc_idx' }
    its(:content) { should include 'tmp_activemq_msgs_pc_asc_idx' }
    its(:content) { should include 'tmp_activemq_msgs_pcx_asc_idx' }
    its(:content) { should include 'tmp_activemq_msgs_pcp_idx' }
    its(:content) { should include 'tmp_activemq_msgs_pxpc_asc_desc_idx' }
    its(:content) { should include 'autovacuum_vacuum_cost_limit=2000' }
    its(:content) { should include 'autovacuum_vacuum_cost_delay=10' }
    its(:content) { should include 'autovacuum_vacuum_scale_factor=0' }
    its(:content) { should include 'autovacuum_vacuum_threshold=5000' }
    its(:content) { should include 'autovacuum_analyze_threshold=1000' }
    its(:content) { should include 'autovacuum_analyze_scale_factor=0.01' }
  end

  describe 'verifying ActiveMQ optimizations for activemq_acks' do
    subject { file('/tmp/activemq_acks.struct') }
    its(:content) { should include 'tmp_activemq_acks_c_idx' }
  end
end
