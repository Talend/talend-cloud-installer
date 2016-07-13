require 'spec_helper_acceptance'

describe 'role::nexus', :if => fact('puppet_roles').split(',').include?('nexus') do
  it_behaves_like 'puppet::appliable', 'include "role::nexus"'
end
