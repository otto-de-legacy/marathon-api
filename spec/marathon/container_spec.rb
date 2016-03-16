require 'spec_helper'

def container_helper type
  return {
    :type => type,
    :docker => {
      :image => 'felixb/yocto-httpd',
      :portMappings => [{:containerPort => 8080}]
    },
    :volumes => [{
      :containerPath => '/data',
      :hostPath => '/var/opt/foo'
    }]
  }
end

describe Marathon::Container do

  context 'when type="DOCKER"' do

    describe '#attributes' do
      subject { described_class.new(container_helper "DOCKER") }

      its(:type) { should == 'DOCKER' }
      its(:docker) { should be_instance_of(Marathon::ContainerDocker) }
      its("docker.portMappings") { should be_instance_of(Array) }
      its("docker.portMappings.first") { should be_instance_of(Marathon::ContainerDockerPortMapping) }
      its("docker.portMappings.first.containerPort") { should == 8080 }
      its(:volumes) { should be_instance_of(Array) }
      its("volumes.first") { should be_instance_of(Marathon::ContainerVolume) }
      its("volumes.first.containerPath") { should == '/data' }
    end

    describe '#to_s' do
      subject { described_class.new(container_helper "DOCKER") }

      let(:expected_string) do
        'Marathon::Container { :type => DOCKER :docker => felixb/yocto-httpd :volumes => /data:/var/opt/foo:RW }'
      end

      its(:to_s) { should == expected_string }
    end

  end

  context 'when type="MESOS"' do

    describe '#attributes' do
      subject { described_class.new(container_helper "MESOS") }

      its(:type) { should == 'MESOS' }
      its(:docker) { should be_instance_of(Marathon::ContainerDocker) }
      its("docker.portMappings") { should be_instance_of(Array) }
      its("docker.portMappings.first") { should be_instance_of(Marathon::ContainerDockerPortMapping) }
      its("docker.portMappings.first.containerPort") { should == 8080 }
      its(:volumes) { should be_instance_of(Array) }
      its("volumes.first") { should be_instance_of(Marathon::ContainerVolume) }
      its("volumes.first.containerPath") { should == '/data' }
    end

    describe '#to_s' do
      subject { described_class.new(container_helper "MESOS") }

      let(:expected_string) do
        'Marathon::Container { :type => MESOS :docker => felixb/yocto-httpd :volumes => /data:/var/opt/foo:RW }'
      end

      its(:to_s) { should == expected_string }
    end

  end

  context 'when type="CHUCK_NORRIS"' do
    describe "#new" do
      it "Should raise Arguement:Error" do
        expected = expect do
          Marathon::Container.new(container_helper "CHUCK_NORRIS")
        end
        expected.to raise_error(Marathon::Error::ArgumentError)
      end
    end
  end
end
