require 'puppetlabs_spec_helper/module_spec_helper'

describe 'profile::web::tomcat' do

  let(:title) { 'profile::web::tomcat' }
  let(:node) { 'rspec.stg.hrs.com' }
  let(:facts) {{  :ipaddress      => '10.42.42.42',
                  :concat_basedir => '/var/lib/puppet/concat',
                  :augeasversion => '1.4.0',
                  :kernel => 'Linux'
  }}

  describe 'building  on Centos' do
    let(:facts) { { :operatingsystem  => 'Centos',
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'RedHat',
                    :augeasversion => '1.4.0',
                    :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
                    :kernel => 'Linux',
                    :architecture => 'x86_64'
    }}

    # Test if it compiles
    it { should compile }
    it { should have_resource_count(28)}

    # Test all default params are set
    it {
      should contain_java__oracle('jdk8')
      should contain_class('tomcat')
    }

  end

  #
  # java::oracle does not support anythin but RedHat by now
  #
  # describe 'building  on Debian' do
  #   let(:facts) { { :operatingsystem  => 'Ubuntu',
  #                   :lsbdistcodename  => 'trusty',
  #                   :lsbdistid => 'Ubuntu',
  #                   :concat_basedir   => '/var/lib/puppet/concat',
  #                   :osfamily         => 'Debian',
  #                   :augeasversion => '1.4.0',
  #                   :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  #                   :kernel => 'Linux',
  #                   :architecture => 'x86_64'
  #   }}
  #
  #   # Test if it compiles
  #   it { should compile }
  #   it { should have_resource_count(26)}
  #
  #   # Test all default params are set
  #   it {
  #     should contain_class('java')
  #     should_not contain_class('selinux')
  #     should contain_class('tomcat')
  #   }
  #end

end

