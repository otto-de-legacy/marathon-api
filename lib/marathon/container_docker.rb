# This class represents a Marathon Container docker information.
# See https://mesosphere.github.io/marathon/docs/native-docker.html for full details.
class Marathon::ContainerDocker < Marathon::Base

  ACCESSORS = %w[ image network ]
  DEFAULTS = {
    :network => 'BRIDGE',
    :portMappings => []
  }

  attr_reader :portMappings

  # Create a new container docker object.
  # ++hash++: Hash returned by API.
  def initialize(hash)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    Marathon::Util.validate_choice('network', network, %w[BRIDGE HOST])
    raise Marathon::Error::ArgumentError, 'image must not be nil' unless image
    @portMappings = (info[:portMappings] || []).map { |e| Marathon::ContainerDockerPortMapping.new(e) }
  end

  def to_pretty_s
    "#{image}"
  end

  def to_s
    "Marathon::ContainerDocker { :image => #{image} }"
  end

end
