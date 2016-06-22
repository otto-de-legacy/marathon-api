require 'spec_helper'

DEPLOYMENT_INFO_EXAMPLE = {
    'deploymentId' => 'deployment-123',
    'version' => 'version-456'
}

describe Marathon::DeploymentInfo do

  describe '#attributes' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE, double(Marathon::MarathonInstance)) }

    its(:deploymentId) { should == 'deployment-123' }
    its(:version) { should == 'version-456' }
  end

  describe '#wait' do
    before(:each) do
      @deployments = double(Marathon::Deployments)
      @subject = described_class.new(DEPLOYMENT_INFO_EXAMPLE,
                                     double(Marathon::MarathonInstance, :deployments => @deployments))
    end

    it 'waits for the deployment' do
      expect(@deployments).to receive(:list) { [] }
      @subject.wait
    end
  end

  describe '#to_s' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      'Marathon::DeploymentInfo { :version => version-456 :deploymentId => deployment-123 }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_s w/o deploymentId' do
    subject { described_class.new({:version => 'foo-version'}, double(Marathon::MarathonInstance)) }

    let(:expected_string) do
      'Marathon::DeploymentInfo { :version => foo-version }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE, double(Marathon::MarathonInstance)) }

    its(:to_json) { should == DEPLOYMENT_INFO_EXAMPLE.to_json }
  end

end
