# This class represents a Marathon Container docker information.
# See https://mesosphere.github.io/marathon/docs/native-docker.html for full details.
class Marathon::ContainerDockerPortMapping < Marathon::Base

  ACCESSORS = %w[ containerPort hostPort servicePort protocol ]
  DEFAULTS = {
    :protocol => 'tcp',
    :hostPort => 0
  }

  # Create a new container docker port mappint object.
  # ++hash++: Hash returned by API.
  def initialize(hash)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    Marathon::Util.validate_choice('protocol', protocol, %w[tcp udp])
    raise Marathon::Error::ArgumentError, 'containerPort must not be nil' unless containerPort
    raise Marathon::Error::ArgumentError, 'containerPort must be a positive number' \
      unless containerPort.is_a?(Integer) and containerPort > 0
    raise Marathon::Error::ArgumentError, 'hostPort must be a non negative number' \
      unless hostPort.is_a?(Integer) and hostPort >= 0
  end

  def to_pretty_s
    "#{protocol}/#{containerPort}:#{hostPort}"
  end

  def to_s
    "Marathon::ContainerDockerPortMapping { :protocol => #{protocol} " \
    + ":containerPort => #{containerPort} :hostPort => #{hostPort} }"
  end

end