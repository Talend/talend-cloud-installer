require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker-rspec/helpers/serverspec'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = [ "Darwin", "windows" ]
WORKDIR = '/tmp/puppet'

unless ENV.has_key?('GIT_BRANCH') then
  GIT_BRANCH = `git branch | grep '^\*' | cut -f2 -d" "`
else
  GIT_BRANCH = ENV['GIT_BRANCH']
end

unless ENV["RS_PROVISION"] == "no" or ENV["BEAKER_provision"] == "no"
  hosts.each do |host|
    on host, 'yum -y install git rubygem-bundler'
    on host, "git clone https://github.com/Talend/talend-cloud-installer.git #{WORKDIR} -b #{GIT_BRANCH}"
    on host, "cd #{WORKDIR} && bundle install --path=vendor/bundle --without development"
    on host, "cp -R #{WORKDIR}/hiera* /etc/puppet/"
    on host, 'mkdir -p /etc/facter/facts.d'

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
      create_remote_file host, '/etc/facter/facts.d/external_facts.txt', "puppet_role=#{host['roles'].first}", :protocol => 'rsync'
      on host,"cd #{WORKDIR} && bundle exec r10k puppetfile install"
    end
  end
end
