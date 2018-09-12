shared_examples 'profile::influxdb' do

  it_behaves_like 'profile::defined', 'influxdb'
  it_behaves_like 'profile::common::packages'

  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
      /var/log/influxdb/influxd.log
  )

  describe service('influxdb') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe port(8083) do
    it { should be_listening }
  end
  describe port(8086) do
    it { should be_listening }
  end

  describe file('/var/lib/influxdb') do
    it do
      should be_mounted.with(
        :type    => 'xfs',
        :options => {
          :rw         => true,
          :noatime    => true,
          :nodiratime => true,
          :noexec     => true
        }
      )
    end
  end

  describe 'Logrotate configuration' do
    subject { file('/etc/logrotate.d/influxdb').content }
    it { should include '/var/log/influxdb/influxd.log' }
    it { should include 'copytruncate' }
    it { should include 'daily' }
    it { should include 'missingok' }
    it { should include 'dateext' }
  end
end
