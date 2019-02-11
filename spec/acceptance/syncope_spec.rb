require 'spec_helper'

describe 'role::syncope' do
  it_behaves_like 'profile::base'
  it_behaves_like 'profile::web::syncope'
  it_behaves_like 'role::defined', 'syncope'
end

describe package('jre1.8') do
  it { should be_installed.with_version('1.8.0_181-fcs') }
end
