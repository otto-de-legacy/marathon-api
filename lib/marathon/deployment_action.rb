# This class represents a Marathon Deployment action.
class Marathon::DeploymentAction < Marathon::Base

  # Create a new deployment action object.
  # ++hash++: Hash returned by API, including 'app' and 'type'
  def initialize(hash)
    super(hash, %w[app type])

  end

  def to_pretty_s
    "#{app}/#{type}"
  end

  def to_s
    "Marathon::DeploymentAction { :app => #{app} :type => #{type} }"
  end

end
