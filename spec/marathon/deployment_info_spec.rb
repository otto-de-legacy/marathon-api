require 'spec_helper'

DEPLOYMENT_INFO_EXAMPLE = {
  'deploymentId' => 'deployment-123',
  'version' => 'version-456'
}

describe Marathon::DeploymentInfo do

  describe '#attributes' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE) }

    its(:deploymentId) { should == 'deployment-123' }
    its(:version) { should == 'version-456' }
  end

  describe '#to_s' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE) }

    let(:expected_string) do
      'Marathon::DeploymentInfo { :deploymentId => deployment-123 :version => version-456 }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new(DEPLOYMENT_INFO_EXAMPLE) }

    its(:to_json) { should == DEPLOYMENT_INFO_EXAMPLE.to_json }
  end

end