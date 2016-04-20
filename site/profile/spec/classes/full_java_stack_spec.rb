require 'puppetlabs_spec_helper/module_spec_helper'

describe 'profile::full_java_stack' do

  let(:title) { 'profile::full_java_stack' }
  let(:node) { 'rspec.stg.hrs.com' }
  let(:facts) {{  :ipaddress      => '10.42.42.42',
                  :concat_basedir => '/var/lib/puppet/concat',
                  :augeasversion => '1.4.0'
  }}

  describe 'building  on Centos' do
    let(:facts) { { :operatingsystem  => 'Centos',
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'RedHat',
                    :augeasversion => '1.4.0'}}

    # Test if it compiles
    it { should compile }
    it { should have_resource_count(44)}

    # Test all default params are set
    it {
      should contain_class('java')
      should contain_class('tomcat')
      should contain_class('nginx')
      #should contain_nginx__resource__vhost('www.puppetlabs.com')
      #should contain_tomcat__config__server__context('mycat-test')
    }

  end

  describe 'building  on Debian' do
    let(:facts) { { :operatingsystem  => 'Ubuntu',
                    :lsbdistcodename  => 'trusty',
                    :lsbdistid => 'Ubuntu',
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'Debian',
                    :augeasversion => '1.4.0'}}

    # Test if it compiles
    it { should compile }
    it { should have_resource_count(53)}

    # Test all default params are set
    it {
      should contain_class('java')
      should_not contain_class('selinux')
      should contain_class('tomcat')
      should contain_class('nginx')
      #should contain_nginx__resource__vhost('www.puppetlabs.com')
    }

  end

end

