shared_examples 'profile::base' do

  it_behaves_like 'profile::defined', 'base'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::packages'
  it_behaves_like 'profile::common::cloudwatch'
  it_behaves_like 'profile::common::cloudwatchlogs'
  it_behaves_like 'profile::common::ssm'
  it_behaves_like 'monitoring::node_exporter'

  describe 'ntp configuration' do
    subject { file('/etc/ntp.conf').content }
    it { should include 'restrict default nomodify notrap nopeer noquery' }
    it { should include 'server 0.amazon.pool.ntp.org iburst' }
    it { should include 'server 1.amazon.pool.ntp.org iburst' }
    it { should include 'server 2.amazon.pool.ntp.org iburst' }
    it { should include 'server 3.amazon.pool.ntp.org iburst' }
  end

  describe 'ntp sync' do
    subject { command('ntpstat').stdout }
    it { should include 'synchronised to' }
    it { should include 'time correct to within' }
  end
end
