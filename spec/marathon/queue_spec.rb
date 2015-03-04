require 'spec_helper'

describe Marathon::Queue do

  describe '#attributes' do
    subject { described_class.new({
        'app'   => { 'id' => '/app/foo' },
        'delay' => { 'overdue' => true }
      }) }

    it 'has app' do
      expect(subject.app).to be_instance_of(Marathon::App)
      expect(subject.app.id).to eq('/app/foo')
    end

    it 'has delay' do
      expect(subject.delay).to be_instance_of(Hash)
      expect(subject.delay['overdue']).to be(true)
    end
  end


  describe '#to_s' do
    subject { described_class.new({
        'app'   => { 'id' => '/app/foo' },
        'delay' => { 'overdue' => true }
      }) }

    let(:expected_string) do
      'Marathon::Queue { :appId => /app/foo :delay => {"overdue"=>true} }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new({
        'app'   => { 'id' => '/app/foo' },
        'delay' => { 'overdue' => true }
      }) }

    let(:expected_string) do
      '{"app":{"id":"/app/foo"},"delay":{"overdue":true}}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '.list' do
    subject { described_class }

    it 'lists queue', :vcr do
      queue = described_class.list
      expect(queue).to be_instance_of(Array)
      expect(queue.first).to be_instance_of(Marathon::Queue)
    end
  end

end