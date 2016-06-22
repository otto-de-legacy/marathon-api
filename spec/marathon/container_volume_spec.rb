require 'spec_helper'

CONTAINER_VOLUME_EXAMPLE = {
    :containerPath => '/data',
    :hostPath => '/var/opt/foo',
    :mode => 'RO'
}

describe Marathon::ContainerVolume do

  describe '#init' do
    subject { described_class }

    it 'should fail with invalid mode' do
      expect { subject.new(:containerPath => '/', :hostPath => '/', :mode => 'foo') }
          .to raise_error(Marathon::Error::ArgumentError, /mode must be one of /)
    end

    it 'should fail with invalid path' do
      expect { subject.new(:hostPath => '/') }
          .to raise_error(Marathon::Error::ArgumentError, /containerPath .* not be nil/)
      expect { subject.new(:containerPath => '/') }
          .to raise_error(Marathon::Error::ArgumentError, /hostPath .* not be nil/)
    end
  end

  describe '#attributes' do
    subject { described_class.new(CONTAINER_VOLUME_EXAMPLE) }

    its(:containerPath) { should == '/data' }
    its(:hostPath) { should == '/var/opt/foo' }
    its(:mode) { should == 'RO' }
  end

  describe '#to_s' do
    subject { described_class.new(CONTAINER_VOLUME_EXAMPLE) }

    let(:expected_string) do
      'Marathon::ContainerVolume { :containerPath => /data :hostPath => /var/opt/foo :mode => RO }'
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == '/data:/var/opt/foo:RO' }
  end

end
