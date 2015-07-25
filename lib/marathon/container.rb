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

  attr_reader :docker, :volumes

  # Create a new container object.
  # ++hash++: Hash returned by API.
  def initialize(hash, conn = Marathon.connection)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), conn, ACCESSORS)
    Marathon::Util.validate_choice('type', type, SUPPERTED_TYPES)
    @docker = Marathon::ContainerDocker.new(info[:docker], conn) if info[:docker]
    @volumes = info[:volumes].map { |e| Marathon::ContainerVolume.new(e, conn) }
  end

  def to_s
    "Marathon::Container { :type => #{type} :docker => #{Marathon::Util.items_to_pretty_s(docker)}"\
    + " :volumes => #{Marathon::Util.items_to_pretty_s(volumes)} }"
  end

end
