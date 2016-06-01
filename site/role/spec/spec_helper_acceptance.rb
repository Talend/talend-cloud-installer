require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = [ "Darwin", "windows" ]
WORKDIR = '/tmp/puppet'

# Load shared acceptance examples
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__), 'acceptance'))
Dir[base_spec_dir.join('shared/**/*.rb')].sort.each{ |f| require f }

unless ENV.has_key?('GIT_BRANCH') then
  GIT_BRANCH = `git branch | grep '^\*' | cut -f2 -d" "`
else
  GIT_BRANCH = ENV['GIT_BRANCH']
end

# Insall puppet on hosts as well as provision them with role facts
hosts.each do |host|
  install_puppet
  on host, 'mkdir -p /etc/facter/facts.d'
  create_remote_file host,
    '/etc/facter/facts.d/role_facts.txt',
    "puppet_role=#{host['roles'].last}\npuppet_roles=#{host['roles'].join(',')}",
    :protocol => 'rsync'
end

unless ENV["RS_PROVISION"] == "no" or ENV["BEAKER_provision"] == "no"
  hosts.each do |host|
    on host, 'yum -y install git rubygem-bundler'
    on host, "git clone https://github.com/Talend/talend-cloud-installer.git #{WORKDIR} -b #{GIT_BRANCH}"
    on host, "cd #{WORKDIR} && bundle install --path=vendor/bundle --without development"
    on host, "cp -R #{WORKDIR}/hiera* /etc/puppet/"
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
      create_remote_file host, '/etc/facter/facts.d/packagecloud_facts.txt', "packagecloud_master_token=#{ENV['PACKAGECLOUD_MASTER_TOKEN']}", :protocol => 'rsync'
      on host,"cd #{WORKDIR} && bundle exec r10k puppetfile install"
    end
  end
end
