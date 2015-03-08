require 'spec_helper'

CONTAINER_EXAMPLE = {
    :type => 'DOCKER',
    :docker => {
      :image => 'felixb/yocto-httpd',
      :portMappings => [{:containerPort => 8080}]
    },
    :volumes => [{
      :containerPath => '/data',
      :hostPath => '/var/opt/foo'
    }]
  }

describe Marathon::Container do

  describe '#attributes' do
    subject { described_class.new(CONTAINER_EXAMPLE) }

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
    subject { described_class.new(CONTAINER_EXAMPLE) }

    let(:expected_string) do
      'Marathon::Container { :type => DOCKER :docker => felixb/yocto-httpd :volumes => /data:/var/opt/foo:RW }'
    end

    its(:to_s) { should == expected_string }
  end

end