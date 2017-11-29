require 'spec_helper'

describe 'role::test_launcher' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::docker_host'
  it_behaves_like 'role::defined', 'test_launcher'

  describe package('zip') do
    it { should be_installed }
  end

  describe file('/opt/talend/tmc/tests_variables.sh') do
    it { should be_file }
  end
end
