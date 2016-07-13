shared_examples 'profile::common::packagecloud_repos' do

  %w(talend_other talend_thirdparty).each do |repo|
    describe yumrepo(repo) do
      it { should exist }
      it { should be_enabled }
    end
  end

end
