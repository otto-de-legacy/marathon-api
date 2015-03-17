require 'spec_helper'

describe Marathon::EventSubscriptions do

  describe '.register' do
    subject { described_class }

    it 'registers callback', :vcr do
      json = subject.register('http://localhost/events/foo')
      expect(json).to be_instance_of(Hash)
      expect(json['eventType']).to eq('subscribe_event')
      expect(json['callbackUrl']).to eq('http://localhost/events/foo')
    end
  end

  describe '.list' do
    subject { described_class }

    it 'lists callbacks', :vcr do
      json = subject.list
      expect(json).to be_instance_of(Array)
      expect(json).to include('http://localhost/events/foo')
    end
  end

  describe '.unregister' do
    subject { described_class }

    it 'unregisters callback', :vcr do
      json = subject.unregister('http://localhost/events/foo')
      expect(json).to be_instance_of(Hash)
      expect(json['eventType']).to eq('unsubscribe_event')
      expect(json['callbackUrl']).to eq('http://localhost/events/foo')
    end
  end

end
