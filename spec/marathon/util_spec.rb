require 'spec_helper'

describe Marathon::Util do

  describe '.validate_choice' do
    subject { described_class }

    it 'passes with valid value' do
      described_class.validate_choice('foo', 'bar', %w[f00 bar], false)
    end

    it 'passes with nil value' do
      described_class.validate_choice('foo', nil, %w[f00], true)
    end

    it 'fails with nil value' do
      expect {
        described_class.validate_choice('foo', nil, %w[f00], false)
      }.to raise_error(Marathon::Error::ArgumentError)
    end

    it 'fails with invalid value' do
      expect {
        described_class.validate_choice('foo', 'bar', %w[f00], false)
      }.to raise_error(Marathon::Error::ArgumentError)
    end
  end

  describe '.add_choice' do
    subject { described_class }

    it 'validates choice first' do
      expect(described_class).to receive(:validate_choice).with('foo', 'bar', %w[f00 bar], false)
      described_class.add_choice({}, 'foo', 'bar', %w[f00 bar], false)
    end

    it 'adds choice' do
      opts = {}
      described_class.add_choice(opts, 'foo', 'bar', %w[f00 bar], false)
      expect(opts['foo']).to eq('bar')
    end
  end

end