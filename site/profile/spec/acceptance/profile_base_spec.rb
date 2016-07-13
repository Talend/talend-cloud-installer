require 'spec_helper_acceptance'


describe "profile::base" do
  let(:pp) do
    <<-EOS
        class { 'profile::base':
        }
    EOS
  end

  it_behaves_like "a idempotent resource"
end

describe 'should have base profile configured' do

  describe yumrepo('epel') do
    it { should exist }
    it { should be_enabled }
  end

  describe yumrepo('talend_other') do
    it { should exist }
    it { should be_enabled }
  end

  describe yumrepo('talend_thirdparty') do
    it { should exist }
    it { should be_enabled }
  end

  # describe package('aws-sdk') do
  #   it { is_expected.to be_installed.by('pip') }
  # end

  describe file('/var/log/awslogs.log') do
    its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/audit,\ log stream/ }
    its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/messages,\ log stream/ }
    its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/secure,\ log stream/ }
    its(:content) { should_not match /ERROR:/ }
  end

end

