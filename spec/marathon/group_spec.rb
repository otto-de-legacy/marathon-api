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
            "tasks" => []
        }
    ],
    "dependencies" => [],
    "groups" => []
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
       "    Version:\n" + \
       "Version:"

    end

    # its(:to_s) { should == expected_string }
    # its(:to_pretty_s) { should == expected_pretty_string }
  end

  describe '#start!' do
    before(:each) do
      @groups = double(Marathon::Groups)
      @marathon_instance = double(Marathon::MarathonInstance, :groups => @groups)
      @subject = described_class.new({'id' => '/group/foo'}, @marathon_instance)
    end

    it 'starts the group' do
      expect(@groups).to receive(:start)
                             .with({:dependencies => [], :id => '/group/foo'}) do
        Marathon::DeploymentInfo.new({'version' => 'new-version'}, @marathon_instance)
      end
      expect(@subject.start!.version).to eq('new-version')
    end
  end

  describe '#refresh' do
    before(:each) do

      @groups = double(Marathon::Groups)
      @marathon_instance = double(Marathon::MarathonInstance, :groups => @groups)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end

    it 'refreshes the group' do
      expect(@groups).to receive(:get).with('/app/foo') do
        described_class.new({'id' => '/app/foo', 'refreshed' => true}, @marathon_instance)
      end
      @subject.refresh
      expect(@subject.info[:refreshed]).to be(true)
    end
  end

  describe '#change!' do
    before(:each) do
      @groups = double(Marathon::Groups)
      @marathon_instance = double(Marathon::MarathonInstance, :groups => @groups)
      @subject = described_class.new({'id' => '/app/foo'}, @marathon_instance)
    end

    it 'changes the group' do
      expect(@groups).to receive(:change).with('/app/foo', {:instances => 9000}, false, false)
      @subject.change!('instances' => 9000)
    end

    it 'changes the group and strips :version' do
      expect(@groups).to receive(:change).with('/app/foo', {:instances => 9000}, false, false)
      @subject.change!('instances' => 9000, :version => 'old-version')
    end
  end

  describe '#roll_back!' do
    subject { described_class.new({'id' => '/app/foo', 'instances' => 10}, double(Marathon::MarathonInstance)) }

    it 'changes the group' do
      expect(subject).to receive(:change!).with({'version' => 'old_version'}, false)
      subject.roll_back!('old_version')
    end

    it 'changes the group with force' do
      expect(subject).to receive(:change!).with({'version' => 'old_version'}, true)
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

  describe '.changes' do
    subject { described_class }

    it 'previews changes', :vcr do
      steps = subject.change('/test-group', {'instances' => 20}, false, true)
      expect(steps).to be_instance_of(Array)
    end

    it 'changes the group', :vcr do
      expect(subject.change('/test-group', {'instances' => 2}, true))
          .to be_instance_of(Marathon::DeploymentInfo)
      expect(subject.change('/test-group', {'instances' => 1}, true))
          .to be_instance_of(Marathon::DeploymentInfo)
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'deletes the group', :vcr do
      expect(subject.delete('/test-group', true))
          .to be_instance_of(Marathon::DeploymentInfo)
    end

    it 'fails deleting not existing app', :vcr do
      expect {
        subject.delete('fooo group')
      }.to raise_error(Marathon::Error::NotFoundError)
    end
  end

end
