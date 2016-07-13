require 'spec_helper'

describe 'role::zookeeper' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::zookeeper'
  it_behaves_like 'role::defined', 'zookeeper'
end
