require 'puppetlabs_spec_helper/module_spec_helper'

describe 'profile::db::mongodb' do

  let(:title) { 'profile::db::mongodb' }
  let(:node) { 'mongodb.testnode.com' }
  let(:facts) {{  :ipaddress      => '10.42.42.42',
                  :concat_basedir => '/var/lib/puppet/concat',
                  :osfamily       => 'RedHat',
                  :augeasversion => '1.4.0'}}

  describe 'building  on Centos' do
    let(:facts) { { :operatingsystem  => 'Centos',
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'RedHat',
                    :augeasversion => '1.4.0',
                    :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'}}


    context 'with defaults for all parameters' do

      # Test if it compiles
      it { should compile }
      it { should have_resource_count(16)}

      # Test all default params are set
      it {
        should contain_class('profile::db::mongodb')
        should contain_class('mongodb::client')
        should contain_package('epel-release')
        should contain_class('mongodb::server')      }
    end

  end
end