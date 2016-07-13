shared_examples 'profile::base' do

  it_behaves_like 'profile::defined', 'base'
  it_behaves_like 'profile::common::packagecloud_repos'
  it_behaves_like 'profile::common::packages'
  it_behaves_like 'profile::common::cloudwatchlogs'

end
