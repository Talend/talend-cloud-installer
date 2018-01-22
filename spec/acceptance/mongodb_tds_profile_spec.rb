require 'spec_helper'

describe 'role::mongodb' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::rsyslog'
  it_behaves_like 'profile::mongodb'
  it_behaves_like 'profile::mongodb_tds_profile'
  it_behaves_like 'role::defined', 'mongodb'
end
