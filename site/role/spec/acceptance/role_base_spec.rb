require 'spec_helper_acceptance'

describe "role::base" , :if => fact('puppet_roles').split(',').include?('base') do
  it_behaves_like 'puppet::appliable', 'include "role::base"'


  describe file('/var/log/awslogs.log') do
    # TODO: missing wait condition makes this fail
    # its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/audit,\ log stream/ }
    # its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/messages,\ log stream/ }
    # its(:content) { should match /Log group:\ \/talend\/tic\/base\/var\/log\/secure,\ log stream/ }
    its(:content) { should_not match /ERROR:/ }
  end

  describe vpc = EC2::VPC.new('vpc-22d93b47')  do
    it { is_expected.to be_default_tenancy }
  end

end
