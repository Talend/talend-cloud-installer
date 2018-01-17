shared_examples 'profile::mongodb_default_profile' do
  describe command('/usr/bin/mongo --quiet -u admin -p mypassword ipaas --eval "printjson(db.getUser(\'admin\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"userAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbAdminAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"readWriteAnyDatabase","db":"admin"}' }
    its(:stdout) { should include '{"role":"dbOwner","db":"ipaas"}' }
  end

  describe command('/usr/bin/mongo --quiet -u tpsvc_config -p mypassword configuration --eval "printjson(db.getUser(\'tpsvc_config\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"configuration"}' }
  end

  describe command('/usr/bin/mongo --quiet -u dqdict-user -p mypassword dqdict --eval "printjson(db.getUser(\'dqdict-user\'));" | /usr/bin/tr -d "\t\n "') do
    its(:stdout) { should include '{"role":"dbOwner","db":"dqdict"}' }
  end
end
