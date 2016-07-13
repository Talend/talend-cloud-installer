require 'spec_helper'

describe 'role::nexus' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::nexus'
  it_behaves_like 'role::defined', 'nexus'
end
