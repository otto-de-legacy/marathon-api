require 'spec_helper'

describe Marathon::Base do

  describe '#init' do
    subject { described_class }

    it 'fails with strange input' do
      expect { subject.new('foo') }.to raise_error(Marathon::Error::ArgumentError)
      expect { subject.new({}, 'foo') }.to raise_error(Marathon::Error::ArgumentError)
      expect { subject.new(nil) }.to raise_error(Marathon::Error::ArgumentError)
      expect { subject.new({}, nil) }.to raise_error(Marathon::Error::ArgumentError)
      expect { subject.new([], ['foo']) }.to raise_error(Marathon::Error::ArgumentError)
    end
  end

  describe '#to_json' do
    subject { described_class.new({
        'app' => { 'id' => '/app/foo' },
        :foo  => 'blubb',
        :bar  => 1
      }) }

    let(:expected_string) do
      '{"app":{"id":"/app/foo"},"foo":"blubb","bar":1}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '#attr_readers' do
    subject { described_class.new({
        'foo' => 'blubb',
        :bar  => 1
      }, [:foo, 'bar']) }

    its(:info) { should == {:foo => 'blubb', :bar => 1} }
    its(:foo) { should == 'blubb' }
    its(:bar) { should == 1 }
  end

  describe '#attr_readers, from string array' do
    subject { described_class.new({
        'foo' => 'blubb',
        :bar  => 1
      }, %w[foo bar]) }

    its(:info) { should == {:foo => 'blubb', :bar => 1} }
    its(:foo) { should == 'blubb' }
    its(:bar) { should == 1 }
  end

end