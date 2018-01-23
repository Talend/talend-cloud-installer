shared_examples 'profile::mongodb_tds_profile' do
  describe 'Verifying password overiding' do
    describe command('/usr/bin/mongo --norc --quiet -u provisioning -p mypassword admin --eval "db.help();"') do
      its(:exit_status) { should eq 1 }
    end
  end

  describe 'Verifying provisioning rights' do
    describe command('/usr/bin/mongo --norc --quiet -u provisioning -p isnotmasterpassword admin --eval "printjson(db.getUser(\'provisioning\'));" | /usr/bin/tr -d "\t\n "') do
      its(:stdout) { should include '{"role":"userAdminAnyDatabase","db":"admin"}' }
      its(:stdout) { should include '{"role":"dbAdminAnyDatabase","db":"admin"}' }
      its(:stdout) { should include '{"role":"readWriteAnyDatabase","db":"admin"}' }
    end
  end
end
