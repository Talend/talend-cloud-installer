shared_examples 'profile::common::cloudwatchlogs' do

  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /var/log/audit/audit.log
    /var/log/messages
    /var/log/secure
  )

  describe service('awslogs') do
    it { should be_enabled }
    it { should be_running }

    describe 'log [/var/log/awslogs.log]' do
      subject { file('/var/log/awslogs.log').content }
      it { should_not include 'ERROR:' }
    end
  end

end
