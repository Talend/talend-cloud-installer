source 'http://rubygems.org'

gem 'puppet', '~> 3.8'
gem 'rake'
gem 'tilt'
gem 'librarian-puppet', '~> 3.0'

group :test do
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
end

group :development do
  gem 'vagrant-wrapper'
  gem 'kitchen-vagrant'
end

group :system_tests do
  gem 'test-kitchen'
  gem 'kitchen-ssh'
  gem 'kitchen-puppet', '~> 1.48.2'
  gem 'kitchen-sync'
  gem 'kitchen-verifier-serverspec'
  gem 'net-ssh'
  gem 'serverspec'
  gem 'rspec_junit_formatter'
end
