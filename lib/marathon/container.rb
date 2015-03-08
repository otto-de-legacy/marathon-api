# This class represents a Marathon Container information.
# It is included in App's definition.
# See https://mesosphere.github.io/marathon/docs/native-docker.html for full details.
class Marathon::Container < Marathon::Base

  SUPPERTED_TYPES = %w[ DOCKER ]
  ACCESSORS = %w[ type ]
  DEFAULTS = {
    :type => 'DOCKER',
    :volumes => []
  }

  # Create a new container object.
  # ++hash++: Hash returned by API.
  def initialize(hash)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    Marathon::Util.validate_choice('type', type, SUPPERTED_TYPES)
  end

  # Get container's docker information.
  # This is read only!
  def docker
    if @info[:docker]
      Marathon::ContainerDocker.new(@info[:docker])
    else
      nil
    end
  end

  # Get container's volumes.
  # This is read only!
  def volumes
    @info[:volumes].map { |e| Marathon::ContainerVolume.new(e) }
  end

  def to_s
    "Marathon::Container { :type => #{type} :docker => #{Marathon::Util.items_to_pretty_s(docker)}"\
    + " :volumes => #{Marathon::Util.items_to_pretty_s(volumes)} }"
  end

end