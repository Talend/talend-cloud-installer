shared_examples 'profile::activemq' do

  it_behaves_like 'profile::defined', 'activemq'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::cloudwatchlog_files', %w(/opt/activemq/data/activemq.log)

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

  describe file('/opt/activemq/conf/activemq.xml') do
    its(:content) { should include '<queue physicalName="ipaas.talend.dispatcher.response.queue"/>' }
  end

  describe 'ActiveMQ optimization version table' do
    subject { command('PGPASSWORD=mypassword /usr/bin/psql -q -h localhost -U activemq -d activemq -c "select MAX(version) from tmp_activemq_optimizations where filename = \'postgresql_optimizations.sql\';"') }
    its(:stdout) { should include '0.1' }
  end

  describe 'ActiveMQ optimizations' do
    subject { command('PGPASSWORD=mypassword /usr/bin/psql -q -h localhost -U activemq -d activemq -c \'\\d+ activemq_msgs\'') }
    its(:stdout) { should include 'tmp_activemq_msgs_p_desc_idx' }
    its(:stdout) { should include 'tmp_activemq_msgs_pc_asc_idx' }
    its(:stdout) { should include 'tmp_activemq_msgs_pcx_asc_idx' }
    its(:stdout) { should include 'tmp_activemq_msgs_pcp_idx' }
    its(:stdout) { should include 'tmp_activemq_msgs_pxpc_asc_desc_idx' }
    its(:stdout) { should include 'tmp_activemq_acks_c_idx' }
    its(:stdout) { should include 'autovacuum_vacuum_cost_limit=2000' }
    its(:stdout) { should include 'autovacuum_vacuum_cost_delay=10' }
    its(:stdout) { should include 'autovacuum_vacuum_scale_factor=0' }
    its(:stdout) { should include 'autovacuum_vacuum_threshold=5000' }
    its(:stdout) { should include 'autovacuum_analyze_threshold=1000' }
    its(:stdout) { should include 'autovacuum_analyze_scale_factor=0.01' }
  end
end
