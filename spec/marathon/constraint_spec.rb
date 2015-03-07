require 'spec_helper'

describe Marathon::Constraint do

  describe '#to_s w/o parameter' do
    subject { described_class.new(['hostname', 'UNIQUE']) }

    let(:expected_string) do
      'Marathon::Constraint { :attribute => hostname :operator => UNIQUE }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_s with parameter' do
    subject { described_class.new(['hostname', 'LIKE', 'foo-host']) }

    let(:expected_string) do
      'Marathon::Constraint { :attribute => hostname :operator => LIKE :parameter => foo-host }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new(['hostname', 'LIKE', 'foo-host']) }

    its(:to_json) { should == ['hostname', 'LIKE', 'foo-host'].to_json }
  end

end