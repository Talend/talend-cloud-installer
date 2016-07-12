source "https://rubygems.org"

# We expect you have puppet installed
gem 'puppet', '3.8.4'

gem 'r10k'
gem 'json'
gem 'hiera-eyaml'
gem 'hiera-eyaml-kms'
gem 'aws-sdk-core', '~> 2'
gem 'retries'


group :development do
  gem 'beaker', :git => 'https://github.com/Talend/beaker.git', :branch => 'feature/aws-sdk-v2' # https://tickets.puppetlabs.com/browse/BKR-782
  gem 'beaker-puppet_install_helper'
  gem 'beaker-rspec'
  gem 'puppetlabs_spec_helper', :git => 'https://github.com/Talend/puppetlabs_spec_helper.git'

  gem 'spec'
  gem 'rspec', '~> 3.4'
  gem 'rspec-core', '~> 3.4'
  gem 'rspec-expectations', '~> 3.4'
  gem 'rspec-mocks', '~> 3.4'
  gem 'rspec-support', '~> 3.4'
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts'

  gem 'puppet-lint'
  gem 'puppet-syntax'

  gem 'ci_reporter'
  gem 'serverspec'
  gem 'serverspec-aws-resources', :git => 'https://github.com/Talend/serverspec-aws-resources.git'
end

group :system_tests do
  gem 'librarian-puppet'
  gem 'test-kitchen'
  gem 'kitchen-puppet'
  gem 'kitchen-vagrant'
  gem 'kitchen-sync'
  gem 'vagrant'
end
