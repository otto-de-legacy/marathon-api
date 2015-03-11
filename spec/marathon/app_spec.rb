require 'spec_helper'

describe Marathon::App do

  describe '#to_s' do
    subject { described_class.new({
      'id' => '/app/foo',
      'instances' => 1,
      'tasks' => [],
      'env' => {'FOO' => 'BAR', 'blubb' => 'blah'},
      'constraints' => [['hostname', 'UNIQUE']],
      'uris' => ['http://example.com/big.tar'],
      'version' => 'foo-version'
    }) }

    let(:expected_string) do
      "Marathon::App { :id => /app/foo }"
    end

    let(:expected_pretty_string) do
      "App ID:     /app/foo\n" + \
      "Instances:  0/1\n" + \
      "Command:    \n" + \
      "CPUs:       \n" + \
      "Memory:      MB\n" + \
      "URI:        http://example.com/big.tar\n" + \
      "ENV:        FOO=BAR\n" + \
      "ENV:        blubb=blah\n" + \
      "Constraint: hostname:UNIQUE\n" + \
      "Version:    foo-version"
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == expected_pretty_string }
  end

  describe '#to_json' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    let(:expected_string) do
      '{"constraints":[],"env":{},"ports":[],"uris":[],"id":"/app/foo"}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '#check_read_only' do
    subject { described_class.new({ 'id' => '/ubuntu2' }, true) }

    it 'does not allow changing the app' do
      expect { subject.change!({}) }.to raise_error(Marathon::Error::ArgumentError)
    end
  end

  describe '#container' do
    subject { described_class.new({
      'id' => '/ubuntu2', 'container' => {'type'=>'DOCKER', 'docker'=>{'image'=>'felixb/yocto-httpd'}}
    })}

    it 'has container' do
      expect(subject.container).to be_instance_of(Marathon::Container)
      expect(subject.container.type).to eq('DOCKER')
    end
  end

  describe '#constraints' do
    subject { described_class.new({ 'id' => '/ubuntu2', 'constraints' => [['hostname', 'UNIQUE']] }) }

    it 'has constraints' do
      expect(subject.constraints).to be_instance_of(Array)
      expect(subject.constraints.first).to be_instance_of(Marathon::Constraint)
    end
  end

  describe '#constraints' do
    subject { described_class.new({ 'id' => '/ubuntu2', 'healthChecks' => [{ 'path' => '/ping' }] }) }

    it 'has healthChecks' do
      expect(subject.healthChecks).to be_instance_of(Array)
      expect(subject.healthChecks.first).to be_instance_of(Marathon::HealthCheck)
    end
  end

  describe '#tasks' do
    subject { described_class.new({ 'id' => '/ubuntu2' }) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      subject.info[:tasks] = []
      subject.tasks
    end

    it 'has tasks', :vcr do
      tasks = subject.tasks
      expect(tasks).to be_instance_of(Array)
      expect(tasks.size).to eq(1)
      expect(tasks.first).to be_instance_of(Marathon::Task)
      expect(tasks.first.appId).to eq(subject.id)
    end

    it 'loads tasks from API when not loaded already' do
      subject.info[:tasks] = nil
      expect(subject).to receive(:refresh) { subject.info[:tasks] = [] }
      expect(subject.tasks).to eq([])
    end

    it 'shows already loaded tasks w/o API call' do
      subject.info[:tasks] = []
      expect(subject).not_to receive(:refresh)
      expect(subject.tasks).to eq([])
    end
  end

  describe '#versions' do
    subject { described_class.new({ 'id' => '/ubuntu2' }) }

    it 'loads versions from API' do
      expect(described_class).to receive(:versions).with('/ubuntu2') { ['foo-version'] }
      expect(subject.versions).to eq(['foo-version'])
    end

    it 'loads version from API' do
      expect(described_class).to receive(:version).with('/ubuntu2', 'foo-version') {
        Marathon::App.new({'id' => '/ubuntu2', 'version' => 'foo-version'}, true)
      }
      expect(subject.versions('foo-version').version).to eq('foo-version')
    end
  end

  describe '#start!' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:start) { described_class.new('id' => subject.id) }
      subject.start!
    end

    it 'starts the app' do
      expect(described_class).to receive(:start)
        .with({:constraints=>[], :env=>{}, :ports=>[], :uris=>[], :id=>"/app/foo"}) do
          described_class.new({ 'id' => '/app/foo', 'started' => true })
      end
      subject.start!
      expect(subject.info[:started]).to be(true)
    end
  end

  describe '#refresh' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:get) { described_class.new('id' => subject.id) }
      subject.refresh
    end

    it 'refreshs the app' do
      expect(described_class).to receive(:get).with('/app/foo') do
        described_class.new({ 'id' => '/app/foo', 'refreshed' => true })
      end
      subject.refresh
      expect(subject.info[:refreshed]).to be(true)
    end
  end

  describe '#restart!' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:restart)
      subject.restart!
    end

    it 'restarts the app' do
      expect(described_class).to receive(:restart)
        .with('/app/foo', false)
      subject.restart!
    end

    it 'restarts the app, force' do
      expect(described_class).to receive(:restart)
        .with('/app/foo', true)
      subject.restart!(true)
    end
  end

  describe '#change!' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:change)
      subject.change!({})
    end

    it 'changes the app' do
      expect(described_class).to receive(:change).with('/app/foo', {:instances => 9000 }, false)
      subject.change!('instances' => 9000, 'version' => 'old-version')
    end
  end

  describe '#roll_back!' do
    subject { described_class.new({:id => '/app/foo', :instances => 10}) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:change)
      subject.roll_back!('old_version')
    end

    it 'changes the app' do
      expect(subject).to receive(:change!).with({:version => 'old_version' }, false)
      subject.roll_back!('old_version')
    end

    it 'changes the app with force' do
      expect(subject).to receive(:change!).with({:version => 'old_version' }, true)
      subject.roll_back!('old_version', true)
    end
  end

  describe '#scale!' do
    subject { described_class.new({:id => '/app/foo', :instances => 10}) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:change)
      subject.scale!(5)
    end

    it 'changes the app' do
      expect(subject).to receive(:change!).with({:instances => 9000}, false)
      subject.scale!(9000)
    end

    it 'changes the app with force' do
      expect(subject).to receive(:change!).with({:instances => 9000}, true)
      subject.scale!(9000, true)
    end
  end

  describe '#suspend!' do
    subject { described_class.new({'id' => '/app/foo', :instances => 10}) }

    it 'checks for read only' do
      expect(subject).to receive(:check_read_only)
      expect(described_class).to receive(:change)
      subject.suspend!
    end

    it 'scales the app to 0' do
      expect(subject).to receive(:scale!).with(0, false)
      subject.suspend!
    end

    it 'scales the app to 0 with force' do
      expect(subject).to receive(:scale!).with(0, true)
      subject.suspend!(true)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'passes arguments to api call' do
      expect(Marathon.connection).to receive(:get)
        .with('/v2/apps', {:cmd => 'foo', :embed => 'apps.tasks'})
        .and_return({ 'apps' => [] })
      subject.list('foo', 'apps.tasks')
    end

    it 'raises error when run with strange embed' do
      expect {
        subject.list(nil, 'foo')
      }.to raise_error(Marathon::Error::ArgumentError)
    end

    it 'lists apps', :vcr do
      apps = subject.list
      expect(apps.size).not_to eq(0)
      expect(apps.first).to be_instance_of(described_class)
      expect(apps.first.cpus).to eq(0.1)
    end

  end

  describe '.start' do
    subject { described_class }

    it 'starts the app', :vcr do
      app = subject.start({
        :id => '/test',
        :cmd => 'sleep 10',
        :instances => 1,
        :cpus => 0.1,
        :mem => 32,
        :version => 'foo-version'
      })
      expect(app).to be_instance_of(described_class)
      expect(app.id).to eq('/test')
      expect(app.instances).to eq(1)
      expect(app.cpus).to eq(0.1)
      expect(app.mem).to eq(32)
    end

    it 'fails getting not existing app', :vcr do
      expect {
        subject.get('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.get' do
    subject { described_class }

    it 'gets the app', :vcr do
      app = subject.get('/ubuntu')
      expect(app).to be_instance_of(described_class)
      expect(app.id).to eq('/ubuntu')
      expect(app.instances).to eq(1)
      expect(app.cpus).to eq(0.1)
      expect(app.mem).to eq(64)
    end

    it 'fails getting not existing app', :vcr do
      expect {
        subject.get('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'deletes the app', :vcr do
      subject.delete('/ubuntu')
    end

    it 'fails deleting not existing app', :vcr do
      expect {
        subject.delete('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.restart' do
    subject { described_class }

    it 'restarts an app', :vcr do
      expect(subject.restart('/ubuntu2')).to be_instance_of(Marathon::DeploymentInfo)
    end

    it 'fails restarting not existing app', :vcr do
      expect {
        subject.restart('fooo app')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.changes' do
    subject { described_class }

    it 'changes the app', :vcr do
      expect(subject.change('/ubuntu2', { 'instances' => 2 }))
        .to be_instance_of(Marathon::DeploymentInfo)
      expect(subject.change('/ubuntu2', { 'instances' => 1 }, true))
        .to be_instance_of(Marathon::DeploymentInfo)
    end

    it 'fails with stange attributes', :vcr do
      expect {
        subject.change('/ubuntu2', { 'instances' => 'foo' })
      }.to raise_error(Marathon::Error::ClientError)
    end
  end

  describe '.versions' do
    subject { described_class }

    it 'gets versions', :vcr do
      versions = subject.versions('/ubuntu2')
      expect(versions).to be_instance_of(Array)
      expect(versions.first).to be_instance_of(String)
    end
  end

  describe '.version' do
    subject { described_class }

    it 'gets a version', :vcr do
      versions = subject.versions('/ubuntu2')
      version = subject.version('/ubuntu2', versions.first)
      expect(version).to be_instance_of(Marathon::App)
      expect(version.read_only).to be(true)
    end
  end
end
