require 'spec_helper'

describe 'role::test' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::docker_host'
  it_behaves_like 'profile::common::packages', %w(ipaas-rt-integration-test)
  it_behaves_like 'role::defined', 'test'

  describe package('ipaas-rt-integration-test') do
    it { should be_installed }
  end

  describe package('talend-cloud-verifier') do
    it { should be_installed }
  end

  describe package('zip') do
    it { should be_installed }
  end

  describe command('/usr/bin/pip show invoke') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/opt/talend/ipaas/rt-integration-test/config.ini') do
    its(:content) { should include '[ipaas-rt-test]' }
    its(:content) { should include 'nexus=http://nexus-host.com' }
    its(:content) { should include 'infra=http://infra-host.com' }
    its(:content) { should include 'iam_scim=http://tpsvc_iam_scim_back_url.com' }
  end
end
