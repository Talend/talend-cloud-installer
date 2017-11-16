shared_examples 'profile::mongodb_versioned' do
  describe package('mongodb-org-server') do
      it { expect(subject).to be_installed.with_version('3.0.15-1.el7') }
      #it { expect(subject).to be_installed.with_version('3.2.17-1.el7') }
      #it { expect(subject).to be_installed.with_version('3.4.10-1.el7') }
  end
end
