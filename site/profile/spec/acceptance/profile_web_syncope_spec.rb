require 'spec_helper_acceptance'

describe "profile::web:syncope" do
  let(:pp) do
    <<-EOS
        class { 'profile::web::syncope':
        }
    EOS
  end

  it_behaves_like "a idempotent resource"
end

describe 'should have web::syncope profile configured' do

  describe package('nginx') do
    it { is_expected.to be_installed }
  end

  describe service('nginx') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe port(80) do
    before { skip("Initial implementation. There are no virtual hosts as of now") }
    it { should be_listening }
  end

  describe port(8080) do
    it { should be_listening }
  end

end