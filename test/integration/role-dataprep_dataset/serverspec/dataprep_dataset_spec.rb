require 'spec_helper'

describe 'role::dataprep_dataset' do
  it_behaves_like 'profile::base'

  describe 'should have dataprep_dataset role configured' do
    it 'should have java process with correct arguments' do
      expect(command('pgrep -a java').stdout).to match /\/opt\/talend\/dataprep\//
    end
  end
end
