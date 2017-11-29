require 'spec_helper'

describe 'role::ecs' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::docker_host'
  it_behaves_like 'role::defined', 'ecs'

  describe service('docker-amazon-ecs-agent') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('/usr/sbin/lvs -o+seg_monitor -a docker') do
    its(:stdout) { should include 'monitored' }
    its(:stdout) { should include 'data_tdata' }
    its(:stdout) { should include 'data_tmeta' }
  end

  describe command('/usr/bin/lsblk -a /dev/sdb') do
    its(:stdout) { should include 'docker-data_tmeta' }
    its(:stdout) { should include 'docker-data_tdata' }
  end

  describe file('/opt/my_jsons/myjson_file.json') do
    its(:content) { should include '"some_string":"some_value"' }
    its(:content) { should include '"some_strings":["string1","string2"]' }
    its(:content) { should include '"some_urls":["https://url1.com/uri","http://localhost/uri"]' }
  end
end
