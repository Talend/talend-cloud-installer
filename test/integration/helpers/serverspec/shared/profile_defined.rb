shared_examples 'profile::defined' do |name|

  describe file('/etc/sysconfig/puppetProfile') do
    it { should be_file }
    its(:content) { should include name }
  end

end
