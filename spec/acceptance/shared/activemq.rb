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

end
