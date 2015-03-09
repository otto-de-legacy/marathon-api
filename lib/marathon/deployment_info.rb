# This class represents a Marathon Deployment information.
# It is returned by asynchronious deployment calls.
class Marathon::DeploymentInfo < Marathon::Base

  # Create a new deployment info object.
  # ++hash++: Hash returned by API, including 'deploymentId' and 'version'
  def initialize(hash)
    super(hash, %w[deploymentId version])
    raise Marathon::Error::ArgumentError, 'version must not be nil' unless version
  end

  def to_s
    if deploymentId
      "Marathon::DeploymentInfo { :version => #{version} :deploymentId => #{deploymentId} }"
    else
      "Marathon::DeploymentInfo { :version => #{version} }"
    end
  end

end