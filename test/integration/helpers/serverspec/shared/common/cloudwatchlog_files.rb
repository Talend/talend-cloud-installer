shared_examples 'profile::common::cloudwatchlog_files' do |files|

  describe service('awslogs') do
    describe 'configuration [/etc/awslogs/awslogs.conf]' do
      subject { file('/etc/awslogs/awslogs.conf').content }
      files.each do |file|
        it { should include "file = #{file}" }
      end
    end
  end

end
