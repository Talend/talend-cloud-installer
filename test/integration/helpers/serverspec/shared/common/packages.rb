shared_examples 'profile::common::packages' do

  describe package('epel-release') do
    it { should be_installed }
  end

  %w(hiera-eyaml hiera-eyaml-kms aws-sdk package_cloud).each do |p|
    describe package(p) do
      it { should be_installed.by('gem') }
    end
  end

  describe yumrepo('epel') do
    it { should exist }
    it { should be_enabled }
  end

end
