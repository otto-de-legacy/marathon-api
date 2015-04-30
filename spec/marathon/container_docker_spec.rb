require 'spec_helper'

CONTAINER_DOCKER_EXAMPLE = {
    :network    => 'HOST',
    :image      => 'felixb/yocto-httpd',
    :privileged =>  false
  }

describe Marathon::ContainerDocker do

  describe '#init' do
    subject { described_class }

    it 'should fail with invalid network' do
      expect { subject.new(:network => 'foo', :image => 'foo') }
        .to raise_error(Marathon::Error::ArgumentError, /network must be one of /)
    end

    it 'should fail w/o image' do
      expect { subject.new({}) }
        .to raise_error(Marathon::Error::ArgumentError, /image must not be/)
    end
  end

  describe '#attributes' do
    subject { described_class.new(CONTAINER_DOCKER_EXAMPLE) }

    its(:network) { should == 'HOST' }
    its(:image) { should == 'felixb/yocto-httpd' }
    its(:portMappings){ should == [] }
    its(:privileged){ should == false}
  end
  describe '#privileged' do
    subject { described_class.new({
        :network    => 'HOST',
        :image      => 'felixb/yocto-httpd',
        :privileged =>  true
      })
    }
    its(:privileged){ should == true}
  end

  describe '#to_s' do
    subject { described_class.new(CONTAINER_DOCKER_EXAMPLE) }

    let(:expected_string) do
      'Marathon::ContainerDocker { :image => felixb/yocto-httpd }'
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == 'felixb/yocto-httpd' }
  end

end
