shared_examples 'profile::kafka' do

  it_behaves_like 'profile::defined', 'kafka'
  it_behaves_like 'profile::common::packages'

  it_behaves_like 'profile::common::cloudwatchlog_files', %w(
      /opt/kafka/logs/server.log
      /opt/kafka/logs/state-change.log
      /opt/kafka/logs/kafka-request.log
      /opt/kafka/logs/log-cleaner.log
      /opt/kafka/logs/controller.log
      /opt/kafka/logs/kafka-authorizer.log
  )

  describe service('kafka') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  #Kafka
  describe port(9092) do
    it { should be_listening }
  end
  #JMX
  describe port(9990) do
    it { should be_listening }
  end

  describe file('/var/lib/kafka') do
    it do
      should be_mounted.with(
        :type    => 'xfs',
        :options => {
          :rw         => true,
          :noatime    => true,
          :nodiratime => true,
          :noexec     => true
        }
      )
    end
  end

  describe 'Log4j configuration' do
    subject { file('/opt/kafka/config/log4j.properties').content }
    it { should include 'managed by Puppet' }
  end

  describe 'Cloudwatch Kafka specific' do
     subject { file('/opt/cloudwatch-agent/metrics.yaml').content }
     it { should include '    DiskSpaceKafka:' }
  end

   begin
     Facter.zookeeper_nodes
   rescue
     Facter.loadfacts()
   end
   begin
     Facter.kafka_cluster_id
   rescue
     Facter.loadfacts()
   end


  if Facter.value('kafka_cluster_id')
    zookeeperpath = '/' + Facter.value('kafka_cluster_id')
  else
    zookeeperpath = '/testing-kafka'
  end

  if Facter.value('zookeeper_nodes')
    zookeepernodes = ''
    Facter.value('zookeeper_nodes').gsub(/[\s\[\]\"]/, '').split(',').each { |zoonode|
      zookeepernodes += zoonode + ':2181' + zookeeperpath + ','
    }
    #remove last ','
    zookeepernodes.chop!
  else
    zookeepernodes = 'localhost:2181' + zookeeperpath
  end

  #Verifying topics creation
  describe "Verifying topic creation on zookeeper '" + zookeepernodes + "'" do
    subject { command('/opt/kafka/bin/kafka-topics.sh --list --zookeeper "'+ zookeepernodes + '"').stdout }
    it { should include 'dispatcher' }
    it { should include 'container-manager' }
    it { should include 'container-events' }
    it { should_not include 'tpsvclogs' }
    it { should_not include 'zipkin' }
  end

  describe "Verifying topic sharding on zookeeper '" + zookeepernodes + "' for dispatcher" do
    subject { command('/opt/kafka/bin/kafka-topics.sh --describe --topic dispatcher --zookeeper "'+ zookeepernodes + '"').stdout }
    it { should include 'Topic:dispatcher' }
    it { should include 'PartitionCount:2' }
    it { should include 'ReplicationFactor:1' }
  end

  describe "Verifying topic configuration on zookeeper '" + zookeepernodes + "' for dispatcher" do
    subject { command('/opt/kafka/bin/kafka-configs.sh --zookeeper "'+ zookeepernodes + '" --entity-type topics --entity-name dispatcher --describe').stdout }
    it { should include 'retention.bytes=536870912' }
  end

  #Verifying topic usability
  describe "Sending test message to tpsvclogs" do
    subject { command('echo "this is a very bad test message" | /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic dispatcher').exit_status }
    it { should eq 0 }
  end

  describe "Getting test message" do
     subject { command('timeout --preserve-status 2s /opt/kafka/bin/kafka-console-consumer.sh --zookeeper ' + zookeepernodes + ' --topic dispatcher --from-beginning') }
     its(:exit_status) { should eq 143 }
     its(:stdout) { should include "this is a very bad test message" }
  end

  describe "Verifying no DEBUG messages in /var/log/messages" do
    subject { command('grep " kafka: " /var/log/messages').stdout }
    it { should_not include ' DEBUG ' }
  end

end
