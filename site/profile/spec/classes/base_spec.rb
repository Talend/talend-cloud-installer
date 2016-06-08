require 'puppetlabs_spec_helper/module_spec_helper'

describe 'profile::base' do

  let(:title) { 'profile::base' }
  let(:node) { 'rspec.stg.hrs.com' }
  let(:facts) {{  :ipaddress      => '10.42.42.42',
                  :concat_basedir => '/var/lib/puppet/concat',
                  :augeasversion => '1.4.0'
  }}

  describe 'building  on Centos' do
    let(:facts) { { :operatingsystem  => 'Centos',
                    :concat_basedir   => '/var/lib/puppet/concat',
                    :osfamily         => 'RedHat',
                    :augeasversion => '1.4.0'
    }}

    # Test if it compiles
    it { should compile }
    it { should have_resource_count(17)}

    # Test all default params are set
    it {
      should contain_class('profile::base')
      should contain_class('stdlib')
      should contain_class('selinux')
    }

    context 'on AWS ' do
      let(:facts) { { :operatingsystem  => 'CentOS',
                      :operatingsystemmajrelease => '7',
                      :lsbdistcodename  => 'trusty',
                      :concat_basedir   => '/var/lib/puppet/concat',
                      :ec2_metadata     => '{ :some =>  \'ec2 content\'}',
                      :osfamily         => 'Redhat'}}
      it { should contain_class('awscli') }
    end
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
    it { should have_resource_count(15)}

    # Test all default params are set
    it {
      should contain_class('profile::base')
      should contain_class('stdlib')
      should_not contain_class('selinux')
    }
    context 'on AWS ' do
      let(:facts) { { :operatingsystem  => 'Ubuntu',
                      :lsbdistcodename  => 'trusty',
                      :lsbdistid => 'Ubuntu',
                      :concat_basedir   => '/var/lib/puppet/concat',
                      :ec2_metadata     => '{ :some =>  \'ec2 content\'}',
                      :osfamily         => 'Debian'}}
      it { should contain_class('awscli') }
    end
  end

end

