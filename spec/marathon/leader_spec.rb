require 'spec_helper'

describe Marathon::Leader do

  describe '.get', :vcr do
    subject { described_class }

    let(:expected_string) { 'mesos:8080' }

    its(:get) { should == expected_string }
  end

  describe '.delete', :vcr do
    subject { described_class }

    let(:expected_string) { 'Leadership abdicted' }

    its(:delete) { should == expected_string }
  end

end