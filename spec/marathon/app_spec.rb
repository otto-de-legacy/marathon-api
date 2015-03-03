require 'spec_helper'

describe Marathon::App do

  describe '#to_s' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    let(:expected_string) do
      "Marathon::App { :id => /app/foo }"
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    let(:expected_string) do
      '{"id":"/app/foo"}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '#tasks' do
    subject { described_class.new({ 'id' => '/ubuntu2' }) }

    it 'has tasks', :vcr do
      tasks = subject.tasks
      expect(tasks).to be_instance_of(Array)
      expect(tasks.size).to eq(1)
      expect(tasks.first).to be_instance_of(Marathon::Task)
      expect(tasks.first.appId).to eq(subject.id)
    end

    it 'loads tasks from API when not loaded already' do
      subject.json['tasks'] = nil
      expect(subject).to receive(:refresh!) { subject.json['tasks'] = [] }
      expect(subject.tasks).to eq([])
    end

    it 'shows already loaded tasks w/o API call' do
      subject.json['tasks'] = []
      expect(subject).not_to receive(:refresh!)
      expect(subject.tasks).to eq([])
    end
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
        .with('/app/foo', false)
      app.restart!
    end

    it 'restarts the app, force' do
      expect(described_class).to receive(:restart)
        .with('/app/foo', true)
      app.restart!(true)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'passes arguments to api call' do
      expect(Marathon.connection).to receive(:get)
        .with('/v2/apps', {:cmd => 'foo', :embed => 'apps.tasks'})
        .and_return({ 'apps' => [] })
      described_class.list('foo', 'apps.tasks')
    end

    it 'raises error when run with strange embed' do
      expect {
        described_class.list(nil, 'foo')
      }.to raise_error(Marathon::Error::ArgumentError)
    end

    it 'lists apps', :vcr do
      apps = described_class.list
      expect(apps.size).to eq(2)
      expect(apps.first).to be_instance_of(described_class)
      expect(apps.first.id).to eq('/ubuntu')
      expect(apps.first.cpus).to eq(0.1)
      expect(apps.first.mem).to eq(64)
    end

  end

  describe '.start' do
    subject { described_class }

    it 'starts the app', :vcr do
      app = described_class.start({ :id => '/test', :cmd => 'sleep 10', :instances => 1, :cpus => 0.1, :mem => 32})
      expect(app).to be_instance_of(described_class)
      expect(app.id).to eq('/test')
      expect(app.instances).to eq(1)
      expect(app.cpus).to eq(0.1)
      expect(app.mem).to eq(32)
    end

    it 'fails getting not existing app', :vcr do
      expect {
        described_class.get('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
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