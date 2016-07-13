require 'spec_helper_acceptance'

describe 'role::syncope' , :if => fact('puppet_roles').split(',').include?('syncope') do
  it_behaves_like 'puppet::appliable', 'include "role::syncope"'

  context 'should have syncope role configured' do

    describe package('nginx') do
      it { is_expected.to be_installed }
    end

    describe service('nginx') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(80) do
      it { should be_listening }
    end

    it 'should have java process with correct arguments' do
      expect(command('pgrep -a java').stdout).to match /\/opt\/tomcat\//
    end

    describe port(8080) do
      it { should be_listening }
    end

  end
end
