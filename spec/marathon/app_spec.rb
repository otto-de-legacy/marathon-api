require 'spec_helper'

describe Marathon::App do

  describe '#to_s' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    let(:expected_string) do
      "Marathon::App { :id => /app/foo }"
    end

    its(:to_s) { should == expected_string }
  end

  describe '#start!' do
    let(:app) { described_class.new({ 'id' => '/app/foo' }) }

    it 'starts the app' do
      expect(described_class).to receive(:start).with({ 'id' => '/app/foo'}) do
        described_class.new({ 'id' => '/app/foo', 'started' => true })
      end
      app.start!
      expect(app.json['started']).to be(true)
    end
  end

  describe '#refresh!' do
    let(:app) { described_class.new({ 'id' => '/app/foo' }) }

    it 'refreshs the app' do
      expect(described_class).to receive(:get).with('/app/foo') do
        described_class.new({ 'id' => '/app/foo', 'refreshed' => true })
      end
      app.refresh!
      expect(app.json['refreshed']).to be(true)
    end
  end

  describe '#restart!' do
    let(:app) { described_class.new({ 'id' => '/app/foo' }) }

    it 'restarts the app' do
      expect(described_class).to receive(:restart)
        .with('/app/foo', {:force => false})
      app.restart!
    end

    it 'restarts the app, force' do
      expect(described_class).to receive(:restart)
        .with('/app/foo', {:force => true})
      app.restart!(true)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'lists apps', :vcr do
      apps = described_class.list
      expect(apps.size).to eq(2)
      expect(apps.first).to be_instance_of(described_class)
      expect(apps.first.id).to eq('/ubuntu')
      expect(apps.first.cpus).to eq(0.1)
      expect(apps.first.mem).to eq(64)
    end

  end

  describe '.get' do
    subject { described_class }

    it 'gets the app', :vcr do
      app = described_class.get('/ubuntu')
      expect(app).to be_instance_of(described_class)
      expect(app.id).to eq('/ubuntu')
      expect(app.instances).to eq(1)
      expect(app.cpus).to eq(0.1)
      expect(app.mem).to eq(64)
    end

    it 'fails getting not existing app', :vcr do
      expect {
        described_class.get('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'deletes the app', :vcr do
      described_class.delete('/ubuntu')
    end

    it 'fails deleting not existing app', :vcr do
      expect {
        described_class.delete('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.restart' do
    subject { described_class }

    it 'fails restarting not existing app', :vcr do
      expect {
        described_class.restart('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

end