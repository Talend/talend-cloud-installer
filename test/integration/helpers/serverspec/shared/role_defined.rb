shared_examples 'role::defined' do |name|

  describe file('/etc/sysconfig/puppetRole') do
    it { should be_file }
    its(:content) { should include name }
  end

end
