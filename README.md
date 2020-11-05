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

## Ruby setup with asdf

You may need to do a special setup for ruby with [asdf](https://asdf-vm.com/#/):

### Step 1: you need OpenSSL 1.0

``` bash
sudo mkdir /opt/github-libs && sudo chmod 777 /opt/github-libs
cd /opt/github-libs
mkdir src out
cd src
git clone git@github.com:openssl/openssl.git --branch OpenSSL_1_0_2-stable
cd openssl
./config --prefix=/opt/github-libs/out/OpenSSL_1_0_2-stable --openssldir=/opt/github-libs/out/OpenSSL_1_0_2-stable/ssl shared zlib -fPIC
make depend
make
make install
make clean
```

### Step 2: Compile ruby with openssl 1.0

``` bash
cd $YOUR_TALEND_CLOUD_INSTALLER_DIR
LDFLAGS="-L/opt/github-libs/out/OpenSSL_1_0_2-stable/lib" CPPFLAGS="-I/opt/github-libs/out/OpenSSL_1_0_2-stable/include/openssl" RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/github-libs/out/OpenSSL_1_0_2-stable" asdf install ruby 2.0.0-p648
```

### Step 3: Install bundler

We need first to update the certificate because our openssl 1.0 has a bad configuration by default

``` bash
ruby --version
ruby 2.0.0p648 (2015-12-16 revision 53162) [x86_64-linux]

curl -fsSL curl.haxx.se/ca/cacert.pem -o $(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')
```

then install bundler

``` bash
gem install bundler --version '=1.13.6'
# Because of a bug, we have to reshim
asdf reshim
```

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

