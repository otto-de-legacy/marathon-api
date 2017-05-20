require 'spec_helper'

describe Marathon do

  describe '.url=' do
    subject { described_class }

    it 'sets new url' do
      described_class.url = 'http://foo'
      expect(described_class.url).to eq('http://foo')

      # reset connection after running this spec
      described_class.url = nil
    end

    it 'resets connection' do
      old_connection = described_class.connection
      described_class.url = 'http://bar'

      expect(described_class.connection).not_to be(old_connection)

      # reset connection after running this spec
      described_class.url = nil
    end
  end

  describe '.options=' do
    subject { described_class }

    it 'sets new options' do
      described_class.options = {:foo => 'bar'}
      expect(described_class.options).to eq({:foo => 'bar'})

      # reset connection after running this spec
      described_class.options = nil
    end

    it 'resets connection' do
      old_connection = described_class.connection
      described_class.options = {:foo => 'bar'}

      expect(described_class.connection).not_to be(old_connection)

      # reset connection after running this spec
      described_class.options = nil
    end

    it 'adds :basic_auth options for :username and :password' do
      described_class.options = {:username => 'user', :password => 'password'}
      expect(described_class.connection.options)
          .to eq({:basic_auth => {:username => 'user', :password => 'password'}})

      # reset connection after running this spec
      described_class.options = nil
    end
  end

  describe '.info' do
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

  describe '.metrics' do
    subject { described_class }

    let(:metrics) { subject.metrics }
    let(:keys) do
      %w[ version gauges counters histograms meters timers ]
    end

    it 'returns the metrics hash', :vcr do
      expect(metrics).to be_a Hash
      expect(metrics.keys.sort).to eq keys.sort
    end
  end

  describe '.ping', :vcr do
    subject { described_class }
    let(:ping) { subject.ping }

    it 'returns pong' do
      ping.should == "pong\n"
    end

    it 'handles incorrect content type' do
      ping.should =~ /pong/
    end
  end
end
