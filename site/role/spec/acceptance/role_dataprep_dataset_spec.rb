require 'spec_helper_acceptance'

describe 'role::dataprep_dataset', :if => fact('puppet_roles').split(',').include?('dataprep_dataset') do
  it_behaves_like 'puppet::appliable', 'include "role::dataprep_dataset"'

  describe 'should have dataprep_dataset role configured' do
    it 'should have java process with correct arguments' do
      expect(command('pgrep -a java').stdout).to match /\/opt\/talend\/dataprep\//
    end
  end
end
