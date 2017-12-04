Table of Contents
=================

  * [What You Get From This control\-repo](#what-you-get-from-this-control-repo)
  * [Requirements](#requirements)
  * [Setup](#setup)


# What You Get From This control-repo

This repository exists as a talend cloud installer control-repo that is used with R10k.

The major points are:
 - An environment.conf that correctly implements:
   - A site directory for roles, profiles, and any custom modules for your organization
   - A config_version script
 - Provided config_version scripts to output the commit of code that your agent just applied
 - Basic example of roles/profiles code
 - Example hieradata directory with pre-created common.yaml and nodes directory
   - These match the default hierarchy that ships with PE

# Requirements
  - Epel Repository
  - Ruby >= 1.9.3
  - Bundler >= 1.11.0
  - ruby-augeas
# Setup
## Install
Clone this repo
``` bash
git clone git@github.com:Talend/talend-cloud-installer.git
```

## Apply Changes
Apply configurations within this repository with
``` bash
sh scripts/setup.sh
```
This runs bundler and a puppet apply with --noop enabled

## Testing Setup
Run bundler inside the checkout to statisfy requirents
``` bash
bundle install --path=vendor/bundle --without=development
```
Run puppet-rspec test for all site modules with
``` bash
sh scripts/test_runner.sh
```

## Development tests
[You need vagrant installed for this](https://www.vagrantup.com/downloads.html) and VirtualBox and at least 6Go RAM free.

To see the script usage:

``` bash
script/local_dev_tests.sh -h
```

Launching all the test, cleaning everything before:

``` bash
script/local_dev_tests.sh -c
```


For manually running rspec or beaker test per module change in the module dir and manually run
 ``` bash
 bundle exec rake beaker
 ```

