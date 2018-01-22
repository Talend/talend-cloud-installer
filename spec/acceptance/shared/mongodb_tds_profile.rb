shared_examples 'profile::mongodb_tds_profile' do
  describe command('/usr/bin/mongo --quiet -u tds -p mypassword tds --eval "printjson(db.getUser(\'tds\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"tds"}' }
  end
end
