require 'spec_helper'

describe Marathon::App do

  describe '#to_s' do
    subject { described_class.new({
                                      'id' => '/app/foo',
                                      'instances' => 1,
                                      'tasks' => [],
                                      'container' => {
                                          :type => 'DOCKER', 'docker' => {'image' => 'foo/bar:latest'},
                                      },
                                      'env' => {'FOO' => 'BAR', 'blubb' => 'blah'},
                                      'constraints' => [['hostname', 'UNIQUE']],
                                      'fetch' => [
                                        { 'uri' => 'http://example.com/big.tar' },
                                      ],
                                      'labels' => {'abc' => '123'},
                                      'version' => 'foo-version'
                                  }, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      "Marathon::App { :id => /app/foo }"
    end

    let(:expected_pretty_string) do
      "App ID:     /app/foo\n" + \
      "Instances:  0/1\n" + \
      "Command:    \n" + \
      "CPUs:       \n" + \
      "Memory:      MB\n" + \
      "Docker:     foo/bar:latest\n" + \
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
    subject { described_class.new({'id' => '/app/foo'}, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      '{"env":{},"labels":{},"id":"/app/foo"}'
    end

    its(:to_json) { should == expected_string }
  end

  describe '#check_read_only' do
    subject { described_class.new({'id' => '/ubuntu2'}, double(Marathon::MarathonInstance), true) }

    it 'does not allow changing the app' do
      expect { subject.change!({}) }.to raise_error(Marathon::Error::ArgumentError)
    end
  end

  describe '#container' do
    subject { described_class.new({
                                      'id' => '/ubuntu2',
                                      'container' => {
                                          'type' => 'DOCKER',
                                          'docker' => {'image' => 'felixb/yocto-httpd'}
                                      }
                                  }, double(Marathon::MarathonInstance)) }

    it 'has container' do
      expect(subject.container).to be_instance_of(Marathon::Container)
      expect(subject.container.type).to eq('DOCKER')
    end
  end

  describe '#constraints' do
    subject { described_class.new({'id' => '/ubuntu2', 'constraints' => [['hostname', 'UNIQUE']]},
                                  double(Marathon::MarathonInstance)) }

    it 'has constraints' do
      expect(subject.constraints).to be_instance_of(Array)
      expect(subject.constraints.first).to be_instance_of(Marathon::Constraint)
    end
  end

  describe '#labels' do
    describe 'w/ lables' do
      subject { described_class.new({'id' => '/ubuntu2', 'labels' => {'env' => 'abc', 'xyz' => '123'}},
                                    double(Marathon::MarathonInstance)) }
      it 'has keywordized labels' do
        expect(subject.labels).to be_instance_of(Hash)
        expect(subject.labels).to have_key(:env)
      end


    end

    describe 'w/o labels' do
      subject { described_class.new({'id' => '/ubuntu2'}, double(Marathon::MarathonInstance)) }
      it 'has empty labels' do
        expect(subject.labels).to eq({})
      end
    end
  end

  describe '#constraints' do
    subject { described_class.new({'id' => '/ubuntu2', 'healthChecks' => [{'path' => '/ping'}]},
                                  double(Marathon::MarathonInstance)) }

    it 'has healthChecks' do
      expect(subject.healthChecks).to be_instance_of(Array)
      expect(subject.healthChecks.first).to be_instance_of(Marathon::HealthCheck)
    end
  end

  describe '#tasks' do
    subject { described_class.new({'id' => '/ubuntu2'}, double(Marathon::MarathonInstance)) }

    it 'shows already loaded tasks w/o API call' do
      subject.info[:tasks] = []
      expect(subject).not_to receive(:refresh)
      expect(subject.tasks).to eq([])
    end
  end

  describe '#versions' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({'id' => '/ubuntu2'}, @marathon_instance)
    end

    it 'loads versions from API' do
      expect(@apps).to receive(:versions).with('/ubuntu2') { ['foo-version'] }
      expect(@subject.versions).to eq(['foo-version'])
    end

    it 'loads version from API' do
      expect(@apps).to receive(:version).with('/ubuntu2', 'foo-version') {
        Marathon::App.new({'id' => '/ubuntu2', 'version' => 'foo-version'}, true)
      }
      expect(@subject.versions('foo-version').version).to eq('foo-version')
    end
  end

  describe '#start!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end

    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:change).with(
          '/app/foo',
          {:env => {}, :labels => {}, :id => "/app/foo"},
          false
      )
      @subject.start!
    end

    it 'starts the app' do
      expect(@apps).to receive(:change)
                           .with(
                               '/app/foo',
                               {:env => {}, :labels => {}, :id => "/app/foo"},
                               false
                           )
      @subject.start!
    end
  end

  describe '#refresh' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end

    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:get) { described_class.new({'id' => @subject.id}, double(Marathon::MarathonInstance)) }
      @subject.refresh
    end

    it 'refreshs the app' do
      expect(@apps).to receive(:get).with('/app/foo') do
        described_class.new({'id' => '/app/foo', 'refreshed' => true}, double(Marathon::MarathonInstance))
      end
      @subject.refresh
      expect(@subject.info[:refreshed]).to be(true)
    end

    it 'returns the app' do
      expect(@apps).to receive(:get).with('/app/foo') do
        described_class.new({'id' => '/app/foo'}, double(Marathon::MarathonInstance))
      end
      expect(@subject.refresh).to be @subject
    end
  end

  describe '#restart!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end


    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:restart)
      @subject.restart!
    end

    it 'restarts the app' do
      expect(@apps).to receive(:restart)
                           .with('/app/foo', false)
      @subject.restart!
    end

    it 'restarts the app, force' do
      expect(@apps).to receive(:restart)
                           .with('/app/foo', true)
      @subject.restart!(true)
    end
  end

  describe '#change!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end

    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:change)
      @subject.change!({})
    end

    it 'changes the app' do
      expect(@apps).to receive(:change).with('/app/foo', {:instances => 9000}, false)
      @subject.change!('instances' => 9000, 'version' => 'old-version')
    end
  end

  describe '#roll_back!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({:id => '/app/foo', :instances => 10}, @marathon_instance)
    end


    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:change)
      @subject.roll_back!('old_version')
    end

    it 'changes the app' do
      expect(@subject).to receive(:change!).with({:version => 'old_version'}, false)
      @subject.roll_back!('old_version')
    end

    it 'changes the app with force' do
      expect(@subject).to receive(:change!).with({:version => 'old_version'}, true)
      @subject.roll_back!('old_version', true)
    end
  end

  describe '#scale!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({:id => '/app/foo', :instances => 10}, @marathon_instance)
    end


    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:change)
      @subject.scale!(5)
    end

    it 'changes the app' do
      expect(@subject).to receive(:change!).with({:instances => 9000}, false)
      @subject.scale!(9000)
    end

    it 'changes the app with force' do
      expect(@subject).to receive(:change!).with({:instances => 9000}, true)
      @subject.scale!(9000, true)
    end
  end

  describe '#suspend!' do
    before(:each) do
      @apps = double(Marathon::Apps)
      @marathon_instance = double(Marathon::MarathonInstance, :apps => @apps)
      @subject = described_class.new({:id => '/app/foo', :instances => 10}, @marathon_instance)
    end

    it 'checks for read only' do
      expect(@subject).to receive(:check_read_only)
      expect(@apps).to receive(:change)
      @subject.suspend!
    end

    it 'scales the app to 0' do
      expect(@subject).to receive(:scale!).with(0, false)
      @subject.suspend!
    end

    it 'scales the app to 0 with force' do
      expect(@subject).to receive(:scale!).with(0, true)
      @subject.suspend!(true)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'passes arguments to api call' do
      expect(Marathon.connection).to receive(:get)
                                         .with('/v2/apps', {:cmd => 'foo', :embed => 'apps.tasks'})
                                         .and_return({'apps' => []})
      subject.list('foo', 'apps.tasks')
    end

    it 'passing id argument to api call' do
      expect(Marathon.connection).to receive(:get)
                                         .with('/v2/apps', {:id => '/app/foo'})
                                         .and_return({'apps' => []})
      subject.list(nil, nil, '/app/foo')
    end

    it 'passing label argument to api call' do
      expect(Marathon.connection).to receive(:get)
                                         .with('/v2/apps', {:label => 'abc'})
                                         .and_return({'apps' => []})
      subject.list(nil, nil, nil, 'abc')
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
    end

  end

  describe '.start' do
    subject { described_class }

    it 'starts the app', :vcr do
      app = subject.start({
                              :id => '/test-app',
                              :cmd => 'sleep 10',
                              :instances => 1,
                              :cpus => 0.1,
                              :mem => 32
                          })
      expect(app).to be_instance_of(described_class)
      expect(app.id).to eq('/test-app')
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
      expect(subject.delete('/test-app'))
          .to be_instance_of(Marathon::DeploymentInfo)
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
      expect(subject.change('/ubuntu2', {'instances' => 2}, true))
          .to be_instance_of(Marathon::DeploymentInfo)
      expect(subject.change('/ubuntu2', {'instances' => 1}, true))
          .to be_instance_of(Marathon::DeploymentInfo)
    end

    it 'fails with stange attributes', :vcr do
      expect {
        subject.change('/ubuntu2', {'instances' => 'foo'})
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
