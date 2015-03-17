require 'spec_helper'

describe Marathon::Leader do

  describe '.get', :vcr do
    subject { described_class }

    its(:get) { is_expected.to be_instance_of(String) }
  end

  describe '.delete', :vcr do
    subject { described_class }

    let(:expected_string) { 'Leadership abdicted' }

    its(:delete) { should == expected_string }
  end

end
