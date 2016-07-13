shared_examples 'profile::web::syncope' do

  it_behaves_like 'profile::defined', 'syncope'
  it_behaves_like 'profile::common::packagecloud_repos'

  describe port(8080) do
    it { should be_listening }
  end

end
