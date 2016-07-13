require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker-rspec/helpers/serverspec'

run_puppet_install_helper

WORKDIR = '/tmp/puppet'

unless ENV.has_key?('GIT_BRANCH') then
  GIT_BRANCH = `git branch | grep '^\*' | cut -f2 -d" "`
else
  GIT_BRANCH = ENV['GIT_BRANCH']
end

unless ENV["RS_PROVISION"] == "no" or ENV["BEAKER_provision"] == "no"
  hosts.each do |host|
    on host, 'yum -y install git rubygem-bundler ruby-devel gcc gcc-c++'
    on host, "git clone https://github.com/Talend/talend-cloud-installer.git #{WORKDIR} -b #{GIT_BRANCH}"
    on host, "cd #{WORKDIR} && bundle install --path=vendor/bundle --without development"
    on host, "cp -R #{WORKDIR}/hiera* /etc/puppet/"
    on host, 'mkdir -p /etc/facter/facts.d'
    on host, 'mkdir -p /root/.aws'
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      c.host = host
      create_remote_file host, '/etc/facter/facts.d/role_facts.txt', "puppet_role=#{host['roles'].last}", :protocol => 'rsync'
      create_remote_file host, '/etc/facter/facts.d/packagecloud_facts.txt', "packagecloud_master_token=#{ENV['PACKAGECLOUD_MASTER_TOKEN']}", :protocol => 'rsync'
      create_remote_file host, '/root/.aws/credentials', "[default]\naws_access_key_id=#{ENV['AWS_ACCESS_KEY_ID']}\naws_secret_access_key=#{ENV['AWS_SECRET_ACCESS_KEY']}}", :protocol => 'rsync'
      create_remote_file host, '/root/.aws/config', "[default]\nregion = us-east-1\noutput = json", :protocol => 'rsync'
      on host,"cd #{WORKDIR} && bundle exec r10k puppetfile install"
    end
  end
end

shared_examples "a idempotent resource" do
  it 'should apply with no errors' do
    apply_manifest(pp, :catch_failures => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules', :hiera_config => '/tmp/puppet/hiera.yaml')
  end

  # it 'should apply a second time without changes', :skip_pup_5016 do
  #   apply_manifest(pp, :catch_changes => true, :modulepath => '/tmp/puppet/site:/tmp/puppet/modules', :hiera_config => '/tmp/puppet/hiera.yaml')
  # end
end