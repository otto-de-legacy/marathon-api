require 'spec_helper'

DEPLOYMENT_STEP_EXAMPLE = {
    "actions" => [
        {"app" => "app1", "type" => "StartApplication"},
        {"app" => "app2", "type" => "StartApplication"}
    ]
}

describe Marathon::DeploymentStep do

  describe '#attributes' do
    subject { described_class.new(DEPLOYMENT_STEP_EXAMPLE) }

    it 'has actions' do
      expect(subject.actions).to be_instance_of(Array)
      expect(subject.actions.size).to eq(2)
      expect(subject.actions.first).to be_instance_of(Marathon::DeploymentAction)
    end
  end

  describe '#to_s' do
    subject { described_class.new(DEPLOYMENT_STEP_EXAMPLE) }

    let(:expected_string) do
      'Marathon::DeploymentStep { :actions => app1/StartApplication,app2/StartApplication }'
    end

    its(:to_s) { should == expected_string }
  end

end
