# This class represents a Marathon Deployment information.
# It is returned by asynchronious deployment calls.
class Marathon::DeploymentInfo

  # Create a new deployment info object.
  # ++hash++: Hash returned by API, including 'deploymentId' and 'version'
  def initialize(hash)
    raise Marathon::Error::ArgumentError, 'hash must be a Hash' unless hash.is_a?(Hash)
    raise Marathon::Error::ArgumentError, 'missing key in hash: deploymentId' unless hash['deploymentId']
    raise Marathon::Error::ArgumentError, 'missing key in hash: version' unless hash['version']
    @info = hash
  end

  # Shortcuts for reaching attributes
  %w[ deploymentId version ].each do |method|
    define_method(method) { |*args, &block| @info[method] }
  end

  def to_s
    "Marathon::DeploymentInfo { :deploymentId => #{deploymentId} :version => #{version} }"
  end

  # Return deployment info as JSON formatted string.
  def to_json
    @info.to_json
  end
end