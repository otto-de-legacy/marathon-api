require 'spec_helper'

CONTAINER_DOCKER_PORT_MAPPING_EXAMPLE = {
    :protocol => 'tcp',
    :hostPort => 0,
    :containerPort => 8080
  }

describe Marathon::ContainerDockerPortMapping do

  describe '#init' do
    subject { described_class }

    it 'should fail with invalid protocol' do
      expect { subject.new(:protocol => 'foo', :containerPort => 8080) }
        .to raise_error(Marathon::Error::ArgumentError, /protocol must be one of /)
    end

    it 'should fail with invalid containerPort' do
      expect { subject.new(:containerPort => 'foo') }
        .to raise_error(Marathon::Error::ArgumentError, /containerPort must be/)
      expect { subject.new(:containerPort => 0) }
        .not_to raise_error
      expect { subject.new(:containerPort => -1) }
        .to raise_error(Marathon::Error::ArgumentError, /containerPort must be/)
    end

    it 'should fail with invalid hostPort' do
      expect { subject.new(:hostPort => 'foo', :containerPort => 8080) }
        .to raise_error(Marathon::Error::ArgumentError, /hostPort must be/)
      expect { subject.new(:hostPort => -1, :containerPort => 8080) }
        .to raise_error(Marathon::Error::ArgumentError, /hostPort must be/)
    end
  end

  describe '#attributes' do
    subject { described_class.new(CONTAINER_DOCKER_PORT_MAPPING_EXAMPLE) }

    its(:protocol) { should == 'tcp' }
    its(:hostPort) { should == 0 }
    its(:containerPort) { should == 8080 }
  end

  describe '#to_s' do
    subject { described_class.new(CONTAINER_DOCKER_PORT_MAPPING_EXAMPLE) }

    let(:expected_string) do
      'Marathon::ContainerDockerPortMapping { :protocol => tcp :containerPort => 8080 :hostPort => 0 }'
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == 'tcp/8080:0' }
  end

end
