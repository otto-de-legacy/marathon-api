# This class represents a Marathon Container Volume information.
# See https://mesosphere.github.io/marathon/docs/native-docker.html for full details.
class Marathon::ContainerVolume < Marathon::Base

  ACCESSORS = %w[ containerPath hostPath mode ]
  DEFAULTS = {
      :mode => 'RW'
  }

  # Create a new container volume object.
  # ++hash++: Hash returned by API.
  def initialize(hash)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    Marathon::Util.validate_choice('mode', mode, %w[RW RO])
    raise Marathon::Error::ArgumentError, 'containerPath must not be nil' unless containerPath
    raise Marathon::Error::ArgumentError, 'containerPath must be an absolute path' \
      unless Pathname.new(containerPath).absolute?
    raise Marathon::Error::ArgumentError, 'hostPath must not be nil' unless hostPath
  end

  def to_pretty_s
    "#{containerPath}:#{hostPath}:#{mode}"
  end

  def to_s
    "Marathon::ContainerVolume { :containerPath => #{containerPath} :hostPath => #{hostPath} :mode => #{mode} }"
  end

end
