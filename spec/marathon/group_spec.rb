require 'spec_helper'

EXAMPLE_GROUP = {
  "id" => "/test-group",
  "apps" => [
      {
          "backoffFactor" => 1.15,
          "backoffSeconds" => 1,
          "maxLaunchDelaySeconds" => 3600,
          "cmd" => "sleep 30",
          "constraints" => [],
          "cpus" => 1.0,
          "dependencies" => [],
          "disk" => 0.0,
          "env" => {},
          "executor" => "",
          "id" => "app",
          "instances" => 1,
          "mem" => 128.0,
          "ports" => [10000],
          "requirePorts" => false,
          "storeUrls" => [],
          "upgradeStrategy" => {
              "minimumHealthCapacity" => 1.0
          },
          "tasks" => [],
          "version" => 'foo-version'
      }
  ],
  "dependencies" => [],
  "groups" => [],
  "version" => 'foo-version'
}

describe Marathon::Group do

  describe '#to_s' do
    subject { described_class.new(EXAMPLE_GROUP) }

    let(:expected_string) do
      "Marathon::Group { :id => /test-group }"
    end

    let(:expected_pretty_string) do
       "Group ID:   /test-group\n" + \
       "    App ID:     app\n" + \
       "    Instances:  0/1\n" + \
       "    Command:    sleep 30\n" + \
       "    CPUs:       1.0\n" + \
       "    Memory:     128.0 MB\n" + \
       "    Version:    foo-version\n" + \
       "Version:    foo-version"

    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == expected_pretty_string }
  end

  describe '#start!' do
    subject { described_class.new({ 'id' => '/group/foo' }) }

    it 'starts the group' do
      expect(described_class).to receive(:start)
        .with({:apps=>[], :dependencies=>[], :groups=>[], :id=>'/group/foo'}) do
          Marathon::DeploymentInfo.new({ 'version' => 'new-version' })
      end
      expect(subject.start!.version).to eq('new-version')
    end
  end

  describe '#refresh' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'refreshs the group' do
      expect(described_class).to receive(:get).with('/app/foo') do
        described_class.new({ 'id' => '/app/foo', 'refreshed' => true })
      end
      subject.refresh
      expect(subject.info[:refreshed]).to be(true)
    end
  end

  describe '#change!' do
    subject { described_class.new({ 'id' => '/app/foo' }) }

    it 'changes the group' do
      expect(described_class).to receive(:change).with('/app/foo', {:instances => 9000 }, false)
      subject.change!('instances' => 9000)
    end

    it 'changes the group and strips :version' do
      expect(described_class).to receive(:change).with('/app/foo', {:instances => 9000 }, false)
      subject.change!('instances' => 9000, :version => 'old-version')
    end
  end

  describe '#roll_back!' do
    subject { described_class.new({ 'id' => '/app/foo', 'instances' => 10 }) }

    it 'changes the group' do
      expect(subject).to receive(:change!).with({'version' => 'old_version' }, false)
      subject.roll_back!('old_version')
    end

    it 'changes the group with force' do
      expect(subject).to receive(:change!).with({'version' => 'old_version' }, true)
      subject.roll_back!('old_version', true)
    end
  end

  describe '.start' do
    subject { described_class }

    it 'starts the group', :vcr do
      expect(subject.start(EXAMPLE_GROUP)).to be_instance_of(Marathon::DeploymentInfo)
    end

    it 'fails getting not existing group', :vcr do
      expect {
        subject.get('fooo group')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'lists apps', :vcr do
      groups = subject.list
      expect(groups).to be_instance_of(described_class)
      expect(groups.groups.size).not_to eq(0)
      expect(groups.groups.first).to be_instance_of(described_class)
    end
  end

  describe '.get' do
    subject { described_class }

    it 'gets the group', :vcr do
      group = subject.get('/test-group')
      expect(group).to be_instance_of(described_class)
      expect(group.id).to eq('/test-group')
      expect(group.apps.first).to be_instance_of(Marathon::App)
    end

    it 'fails getting not existing app', :vcr do
      expect {
        subject.get('fooo group')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'deletes the group', :vcr do
      subject.delete('/test-group', true)
    end

    it 'fails deleting not existing app', :vcr do
      expect {
        subject.delete('fooo group')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

  describe '.changes' do
    subject { described_class }

    it 'changes the group', :vcr do
      expect(subject.change('/ubuntu2', { 'instances' => 2 }))
        .to be_instance_of(Marathon::DeploymentInfo)
      expect(subject.change('/ubuntu2', { 'instances' => 1 }, true))
        .to be_instance_of(Marathon::DeploymentInfo)
    end
  end

end
