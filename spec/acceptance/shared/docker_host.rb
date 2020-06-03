shared_examples 'profile::docker_host' do

  it_behaves_like 'profile::defined', 'docker_host'

  describe package('docker-ce') do
    it { is_expected.to be_installed }
  end

  describe package('docker-ce-cli') do
    it { is_expected.to be_installed }
  end

  describe package('containerd.io') do
    it { is_expected.to be_installed }
  end

  describe command('/usr/bin/sleep 5') do
    its(:exit_status) { should eq 0 }
  end

  describe docker_container('registry') do
    it { should be_running }
  end

  describe port(5000) do
    it { should be_listening }
  end

  #We test the use of the registry.
  #To push the image on the registry before the test:
  #- Get the registry image from docker:
  #  - docker pull registry:2
  #- Set your s3 bucket, your amazon credentials and launch the registry, example
  #  - docker run -e "REGISTRY_STORAGE=s3" -e "REGISTRY_STORAGE_S3_REGION=us-west-2" -e "REGISTRY_STORAGE_S3_BUCKET=us-east-1-pub-tests-devops-talend-com" -e "REGISTRY_STORAGE_S3_ROOTDIRECTORY=registry" -e "REGISTRY_STORAGE_S3_ACCESSKEY=YourOwnS3AccessKey" -e "REGISTRY_STORAGE_S3_SECRETKEY=YouOwnS3Secret" -d -p 5000:5000 --restart=always --name registry registry:2
  #- Get the hello world image from docker
  #  - docker pull hello-world
  #- Put a new tag to refer your registry
  #  - docker tag hello-world localhost:5000/test/hello-world:latest
  #- Push to your registry
  #  - docker push localhost:5000/test/hello-world:latest
  # Your registry is now ready for this acceptance test
  describe command('/bin/docker pull hello-world') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/bin/docker tag hello-world localhost:5000/test/hello-world:latest') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/bin/docker push localhost:5000/test/hello-world:latest') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/bin/docker pull localhost:5000/test/hello-world:latest') do
    its(:exit_status) { should eq 0 }
  end

  describe docker_image('localhost:5000/test/hello-world:latest') do
    its(['Config.Cmd']) { should include '/hello' }
  end

  describe file('/var/lib/registry/docker/registry/v2/repositories/test/hello-world/_manifests/tags/latest') do
    it { should exist }
    it { should be_directory }
  end
end
