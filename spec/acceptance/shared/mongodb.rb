shared_examples 'profile::mongodb' do

  it_behaves_like 'profile::defined', 'mongodb'
  it_behaves_like 'profile::common::packages'

  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
    /var/log/mongodb/mongod.log
  )

  describe 'Verifying mongod sysctl conf' do
    describe file('/etc/sysctl.d/mongod.conf') do
      it { should be_file }
      its(:content) { should include '# File managed by Puppet, do not edit manually' }
    end
    describe command('/sbin/sysctl -a') do
      its(:stdout) { should include 'kernel.pid_max = 128000' }
      its(:stdout) { should include 'kernel.threads-max = 128000' }
      its(:stdout) { should include 'fs.file-max = 500000' }
      its(:stdout) { should include 'net.ipv4.tcp_keepalive_time = 120' }
      its(:stdout) { should include 'vm.zone_reclaim_mode = 0' }
    end
    describe command('/bin/cat /proc/sys/fs/file-max') do
      its(:stdout) { should include '500000' }
    end
  end

  describe 'Verifying mongod systemd override' do
    describe file('/etc/systemd/system/mongod.service') do
      it { should be_file }
      its(:content) { should include '# File managed by Puppet, do not edit manually' }
      its(:content) { should include 'Type=simple' }
      its(:content) { should include 'LimitNOFILE=128000' }
      its(:content) { should include 'LimitNPROC=128000' }
    end
    describe command('/bin/systemctl --no-pager show mongod.service') do
      its(:stdout) { should include 'Type=simple' }
      its(:stdout) { should include 'LimitNOFILE=128000' }
      its(:stdout) { should include 'LimitNPROC=128000' }
    end
  end

  describe 'Verifying swap' do
    describe file('/var/lib/mongo/mongo.swap') do
      it { should be_file }
    end
    describe command('/sbin/swapon') do
      its(:stdout) { should include '/var/lib/mongo/mongo.swap file' }
    end
  end

  describe 'Verify MongoDB version' do
    describe command('/usr/bin/rpm -q mongodb-org-server') do
      its(:stdout) { should include 'mongodb-org-server-3.6.13-1' }
    end
  end

  describe 'Verify MongoDB major version and facts' do
    describe command('/usr/bin/facter -p mongodb_version') do
      its(:stdout) { is_expected.to match(/^[3]/) }
    end
    describe command('/usr/bin/facter -p mongodb_is_master') do
      # with auth enabled, the mongodb facter can't connect
      its(:stdout) { is_expected.to match(/^(unknown)|(true)\n/) }
    end
  end


  describe 'mongod hugepages off' do
    describe command('/sbin/tuned-adm active') do
      its(:stdout) { should include 'No current active profile.' }
    end
    describe file('/etc/init.d/disable-transparent-hugepages') do
      it { should be_file }
      its(:content) { should include '# File managed by Puppet, do not edit manually' }
    end
    describe command('/sbin/chkconfig --list') do
      its(:stdout) { should include 'disable-transparent-hugepages' }
    end
    describe command('/bin/cat /sys/kernel/mm/transparent_hugepage/enabled') do
      its(:stdout) { should include 'always madvise [never]' }
    end
    describe command('/bin/cat /sys/kernel/mm/transparent_hugepage/defrag') do
      its(:stdout) { should include 'always madvise [never]' }
    end
  end

  describe 'Verifying mongod conf' do
    describe file('/etc/mongod.conf') do
      it { should be_file }
      its(:content) { should include '#mongodb.conf - generated from Puppet' }
      its(:content) { should include '#System Log' }
      its(:content) { should include 'systemLog.destination: syslog' }
      its(:content) { should include 'net.bindIp: ' }
    end
  end

  describe 'Verifying mongod ulimits' do
    describe file('/etc/security/limits.d/mongod.conf') do
      it { should be_file }
      its(:content) { should include '# File managed by Puppet, do not edit manually' }
      its(:content) { should match /\nmongod\s+soft\s+nproc\s+128000\s*\n/ }
      its(:content) { should match /\nmongod\s+hard\s+nproc\s+128000\s*\n/ }
    end
    describe command('/bin/bash -c \'/bin/cat /proc/$(/bin/pgrep -x mongod)/limits\'') do
      its(:stdout) { should match /\nMax processes\s+128000\s+128000\s+processes\s*\n/ }
      its(:stdout) { should match /\nMax open files\s+128000\s+128000\s+files\s*\n/ }
    end
  end

  describe 'Verifying mongodb logging' do
    describe file('/etc/rsyslog.d/10_mongod.conf') do
      it { should be_file }
      its(:content) { should include '# This file is managed by Puppet, changes may be overwritten' }
    end
    describe file('/var/log/mongodb/mongod.log') do
      it { should be_file }
    end
    describe command('/bin/test $(/bin/egrep \'^[a-zA-Z]{3} ([0-9]{2}| [0-9]) [0-9]{2}:[0-9]{2}:[0-9]{2} \' /var/log/mongodb/mongod.log | /bin/wc -l) -gt 3') do
      its(:exit_status) { should eq 0 }
    end
    describe command('/bin/test $(/bin/egrep \'^\s*$\' /var/log/mongodb/mongod.log | /bin/wc -l) -eq 0') do
      its(:exit_status) { should eq 0 }
    end
  end

  describe 'Verifying mongodb auth' do
    describe file('/var/lib/mongo/mongo_auth.flag') do
      it { should be_file }
    end
    describe file('/etc/mongod.conf') do
      it { should be_file }
      its(:content) { should include 'security.authorization: enabled' }
    end
    describe command('/usr/bin/mongo --norc --quiet -u sreadmin -p mypassword admin --eval "db.help();"') do
      its(:exit_status) { should eq 0 }
    end
    describe command('/usr/bin/mongo --norc --quiet -u sreadmin -p mybadpassword admin --eval "db.help();"') do
      its(:exit_status) { should eq 1 }
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

  describe command('/usr/bin/mongo --norc --quiet -u sreadmin -p mypassword admin --eval "printjson(db.getUser(\'sreadmin\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"userAdmin","db":"admin"}' }
    its(:stdout) { should include '{"role":"readWrite","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbAdmin","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"readAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"readWriteAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"userAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"clusterAdmin","db":"admin"}' }
    its(:stdout) { should include '{"role":"clusterManager","db":"admin"}' }
    its(:stdout) { should include '{"role":"clusterMonitor","db":"admin"}' }
    its(:stdout) { should include '{"role":"hostManager","db":"admin"}' }
    its(:stdout) { should include '{"role":"root","db":"admin"}' }
    its(:stdout) { should include '{"role":"restore","db":"admin"}' }
  end

  describe command('/usr/bin/mongo --norc --quiet -u backup -p mypassword admin --eval "printjson(db.getUser(\'backup\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"backupRole","db":"admin"}' }
  end

  describe command('/usr/bin/mongo --norc --quiet -u monitor -p mypassword admin --eval "printjson(db.getUser(\'monitor\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"clusterMonitor","db":"admin"}' }
  end

  describe command('/usr/bin/mongo --norc --quiet -u datadog -p mypassword admin --eval "printjson(db.getUser(\'datadog\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"clusterMonitor","db":"admin"}' }
  end
 
  describe command('/usr/bin/mongo --norc --quiet -u mdreadonly -p mypassword admin --eval "printjson(db.getUser(\'mdreadonly\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"readAnyDatabase","db":"admin"}' }
  end


  describe 'Logrotate configuration' do
    describe file('/etc/logrotate.d/hourly/mongodb_log') do
      it { should be_file }
      its(:content) { should include '# THIS FILE IS AUTOMATICALLY DISTRIBUTED BY PUPPET.' }
      its(:content) { should include '/var/log/mongodb/mongod.log' }
      its(:content) { should include 'compress' }
    end
    describe file('/etc/cron.hourly/logrotate') do
      it { should be_file }
      its(:content) { should include '# THIS FILE IS AUTOMATICALLY DISTRIBUTED BY PUPPET.' }
      its(:content) { should include ' /etc/logrotate.d/hourly ' }
    end
  end

  describe 'credential storage' do
    describe file('/root/.mongorc.js') do
      it { should be_file }
      its(:content) { should include ' db.auth(\'sreadmin\', \'mypassword\')' }
    end
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
end
