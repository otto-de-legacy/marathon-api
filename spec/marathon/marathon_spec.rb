require 'spec_helper'

describe Marathon do

  describe '#info' do
    subject { described_class }

    let(:info) { subject.info }
    let(:keys) do
      %w[ elected event_subscriber frameworkId http_config leader
        marathon_config name version zookeeper_config ]
    end

    it 'returns the info hash', :vcr do
      expect(info).to be_a Hash
      expect(info.keys.sort).to eq keys
    end
  end

  describe '#ping', :vcr do
    subject { described_class }

    its(:ping) { should == "pong\n" }
  end
end