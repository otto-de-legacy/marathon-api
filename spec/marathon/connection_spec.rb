require 'spec_helper'

describe Marathon::Connection do

  describe '#to_s' do
    subject { described_class.new('http://foo:8080') }

    let(:expected_string) do
      "Marathon::Connection { :url => http://foo:8080 :options => {} }"
    end

    its(:to_s) { should == expected_string }
  end

  describe '#request' do
    subject { described_class.new('http://foo.example.org:8080') }

    it 'raises IOError on SocketError' do
      allow(described_class).to receive(:send) { raise SocketError.new }
      expect {
        subject.get('/v2/some/api/path')
      }.to raise_error(Marathon::Error::IOError)
    end

    it 'raises IOError on Errno' do
      allow(described_class).to receive(:send) { raise Errno::EINTR.new }
      expect {
        subject.get('/v2/some/api/path')
      }.to raise_error(Marathon::Error::IOError)
    end

    it 'raises original error when unknown' do
      allow(described_class).to receive(:send) { raise RuntimeError.new }
      expect {
        subject.get('/v2/some/api/path')
      }.to raise_error(RuntimeError)
    end
  end

end