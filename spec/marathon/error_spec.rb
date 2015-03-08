require 'spec_helper'

describe Marathon::Error do

  describe '.error_class' do
    subject { described_class }

    it 'returns ClientError on 400' do
      expect(subject.error_class(Net::HTTPResponse.new(1.1, 400, 'Client Error')))
        .to be(Marathon::Error::ClientError)
    end

    it 'returns ClientError on 422' do
      expect(subject.error_class(Net::HTTPResponse.new(1.1, 422, 'Client Error')))
        .to be(Marathon::Error::ClientError)
    end

    it 'returns NotFoundError on 404' do
      expect(subject.error_class(Net::HTTPResponse.new(1.1, 404, 'Not Found')))
        .to be(Marathon::Error::NotFoundError)
    end

    it 'returns UnexpectedResponseError anything else' do
      expect(subject.error_class(Net::HTTPResponse.new(1.1, 599, 'Whatever')))
        .to be(Marathon::Error::UnexpectedResponseError)
    end
  end

  describe '.error_message' do
    subject { described_class }

    it 'returns "message" from respose json' do
      r = { 'message' => 'fooo' }
      expect(r).to receive(:parsed_response) { r }
      expect(subject.error_message(r)).to eq('fooo')
    end

    it 'returns "errors" from respose json' do
      r = { 'errors' => 'fooo' }
      expect(r).to receive(:parsed_response) { r }
      expect(subject.error_message(r)).to eq('fooo')
    end

    it 'returns full hash from respose json, if keys are missing' do
      r = { 'bars' => 'fooo' }
      expect(r).to receive(:parsed_response) { r }
      expect(subject.error_message(r)).to eq(r)
    end

    it 'returns full body if not a hash with "message"' do
      r = 'fooo'
      expect(r).to receive(:parsed_response) { r }
      expect(subject.error_message(r)).to eq('fooo')
    end
  end

end