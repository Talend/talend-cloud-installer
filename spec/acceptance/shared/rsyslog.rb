shared_examples 'profile::rsyslog' do

  describe 'Verifying rsyslog conf' do
     describe file('/etc/rsyslog.conf') do
       it { should be_file }
       its(:content) { should include '# file is managed by puppet' }
       its(:content) { should include '$IncludeConfig /etc/rsyslog.d/*.conf' }
    end
  end

  describe 'Verifying default logging' do
    describe file('/etc/rsyslog.d/00_client.conf') do
      it { should be_file }
      its(:content) { should include '# This file is managed by Puppet, changes may be overwritten' }
      its(:content) { should include '$template CloudwatchAgent,' }
      its(:content) { should include '$template CloudwatchAgentEOL,' }
      its(:content) { should_not include '/var/log/messages' }
    end
    describe file('/etc/rsyslog.d/99_local_logs.conf') do
      it { should be_file }
      its(:content) { should include '# This file is managed by Puppet, changes may be overwritten' }
      its(:content) { should include '/var/log/messages' }
    end
  end

  describe service('rsyslog') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
