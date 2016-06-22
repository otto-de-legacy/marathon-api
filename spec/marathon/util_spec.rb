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

  describe '.keywordize_hash!' do
    subject { described_class }

    it 'keywordizes the hash' do
      hash = {
          'foo' => 'bar',
          'f00' => {'w00h00' => 'yeah'},
          'bang' => [{'tricky' => 'one'}],
          'env' => {'foo' => 'bar'},
          'null' => nil
      }

      expect(subject.keywordize_hash!(hash)).to eq({
                                                       :foo => 'bar',
                                                       :f00 => {:w00h00 => 'yeah'},
                                                       :bang => [{:tricky => 'one'}],
                                                       :env => {'foo' => 'bar'},
                                                       :null => nil
                                                   })
      # make sure, it changes the hash w/o creating a new one
      expect(hash[:foo]).to eq('bar')
    end
  end

  describe '.remove_keys' do
    subject { described_class }

    it 'removes keys from hash' do
      hash = {
          :foo => 'bar',
          :deleteme => {'w00h00' => 'yeah'},
          :blah => [{:deleteme => :foo}, 1]
      }

      expect(subject.remove_keys(hash, [:deleteme])).to eq({
                                                               :foo => 'bar',
                                                               :blah => [{}, 1]
                                                           })
      # make sure, it does not changes the original hash
      expect(hash.size).to eq(3)
    end
  end

end
