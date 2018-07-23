shared_examples 'profile::postgresql' do |role, databases = []|

  it_behaves_like 'profile::defined', 'postgresql'

  describe package('postgresql-server') do
    it { is_expected.to be_installed }
  end

  describe package('postgresql') do
    it { is_expected.to be_installed }
  end

  describe port(5432) do
    it { should be_listening }
  end

  databases.each do |db|
    describe command("PGPASSWORD=mypassword /usr/bin/psql -P pager -h localhost -U #{role} -d #{role} -c '\\dt'") do
      its(:stdout) { should include db }
    end
  end

end
