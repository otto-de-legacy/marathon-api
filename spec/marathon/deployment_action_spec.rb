require 'spec_helper'

DEPLOYMENT_ACTION_EXAMPLE = { "app" => "app1", "type" => "StartApplication" }

describe Marathon::DeploymentAction do

  describe '#attributes' do
    subject { described_class.new(DEPLOYMENT_ACTION_EXAMPLE) }

    its(:app) { should == 'app1' }
    its(:type) { should == 'StartApplication' }
  end

  describe '#to_s' do
    subject { described_class.new(DEPLOYMENT_ACTION_EXAMPLE) }

    let(:expected_string) do
      'Marathon::DeploymentAction { :app => app1 :type => StartApplication }'
    end

    its(:to_s) { should == expected_string }
    its(:to_pretty_s) { should == 'app1/StartApplication' }
  end

end
