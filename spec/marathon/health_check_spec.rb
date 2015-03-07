require 'spec_helper'

describe Marathon::HealthCheck do

  describe '#init' do
    subject { described_class.new({'protocol' => 'TCP'}) }

    its(:protocol) { should == 'TCP' }
    its(:portIndex) { should == 0 }
    its(:timeoutSeconds) { should == 20 }
  end

  describe '#to_s with protocol==HTTP' do
    subject { described_class.new({'protocol' => 'HTTP', 'portIndex' => 0, 'path' => '/ping'}) }

    let(:expected_string) do
      'Marathon::HealthCheck { :protocol => HTTP :portIndex => 0 :path => /ping }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_s with protocol==TCP' do
    subject { described_class.new({'protocol' => 'TCP', 'portIndex' => 0, 'path' => '/ping'}) }

    let(:expected_string) do
      'Marathon::HealthCheck { :protocol => TCP :portIndex => 0 }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_s with protocol==COMMAND' do
    subject { described_class.new({'protocol' => 'COMMAND', 'command' => 'true'}) }

    let(:expected_string) do
      'Marathon::HealthCheck { :protocol => COMMAND :command => true }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new({'protocol' => 'HTTP', 'portIndex' => 0, 'path' => '/ping'}) }

    its(:to_json) { should == '{"gracePeriodSeconds":300,"intervalSeconds":60,"maxConsecutiveFailures":3,' \
      + '"path":"/ping","portIndex":0,"protocol":"HTTP","timeoutSeconds":20}' }
  end

end