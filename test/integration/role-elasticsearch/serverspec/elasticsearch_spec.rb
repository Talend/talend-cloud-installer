require 'spec_helper'

describe 'role::elasticsearch' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::elasticsearch'
  it_behaves_like 'role::defined', 'elasticsearch'
end
