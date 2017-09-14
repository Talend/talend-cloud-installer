shared_examples 'profile::mongodb' do

  it_behaves_like 'profile::defined', 'mongodb'
  it_behaves_like 'profile::common::packages'

  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /var/log/mongodb/mongod.log
  )

  describe 'Verifying mongod conf' do
     describe file('/etc/mongod.conf') do
       it { should be_file }
       its(:content) { should include '#mongodb.conf - generated from Puppet' }
       its(:content) { should include '#System Log' }
       its(:content) { should include 'systemLog.path: /var/log/mongodb/mongod.log' }
       its(:content) { should include 'systemLog.logAppend: true' }
    end
  end

  describe 'Verifying mongod ulimits' do
    describe file('/etc/security/limits.d/mongod.conf') do
      it { should be_file }
      its(:content) { should include '# File managed by Pupppet, do not edit manually' }
      its(:content) { should match /\nmongod\s+soft\s+nproc\s+64000\s*\n/ }
      its(:content) { should match /\nmongod\s+hard\s+nproc\s+64000\s*\n/ }
    end
    describe command('/bin/bash -c \'/bin/cat /proc/$(/bin/pgrep mongo)/limits\'') do
      its(:stdout) { should include 'Max processes             64000                64000                processes' }
    end
  end

  describe service('mongod') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe package('mongodb-org-tools') do
      it { should be_installed }
  end

  describe port(27017) do
    it { should be_listening }
  end

  describe file('/var/lib/mongo') do
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

  describe command('/usr/bin/lsblk -o KNAME,SIZE,FSTYPE -n /dev/sdb') do
    its(:stdout) { should include 'sdb' }
    its(:stdout) { should include '10G' }
    its(:stdout) { should include 'xfs' }
  end

  describe command('/usr/bin/mongo -u admin -p mypassword ipaas --eval "printjson(db.getUser(\'admin\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"userAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"readWriteAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbOwner","db":"ipaas"}' }
  end

  describe command('/usr/bin/mongo -u tpsvc_config -p mypassword configuration --eval "printjson(db.getUser(\'tpsvc_config\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"configuration"}' }
  end

  describe command('/usr/bin/mongo -u backup -p mypassword admin --eval "printjson(db.getUser(\'backup\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"backupRole","db":"admin"}' }
  end

  describe command('/usr/bin/mongo -u monitor -p mypassword admin --eval "printjson(db.getUser(\'monitor\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"clusterMonitor","db":"admin"}' }
  end

  describe command('/usr/bin/mongo -u datadog -p mypassword admin --eval "printjson(db.getUser(\'datadog\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"clusterMonitor","db":"admin"}' }
  end

  describe command('/usr/bin/mongo -u dqdict-user -p mypassword dqdict --eval "printjson(db.getUser(\'dqdict-user\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"dqdict"}' }
  end

  describe command('/usr/bin/mongo -u dqdict-user -p mypassword dqdict --eval "printjson(db.Document.getIndexes());" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"published.values":1}' }
  end

  describe command('/usr/bin/mongo -u dqdict-user -p mypassword dqdict --eval "printjson(db.Upload.getIndexes());" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"createdAt":1}' }
  end

  describe command('/usr/bin/mongo -u tds -p mypassword tds --eval "printjson(db.getUser(\'tds\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"tds"}' }
  end

  describe 'Logrotate configuration' do
    subject { file('/etc/logrotate.d/mongodb_log').content }
    it { should include '/var/log/mongodb/mongod.log' }
    it { should include 'copytruncate' }
    it { should include 'daily' }
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

  describe 'Cloudwatch MongoDB specific' do
     subject { file('/opt/cloudwatch-agent/metrics.yaml').content }
     it { should include '    DiskSpaceMongoDB:' }
  end

end
