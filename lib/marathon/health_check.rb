# This class represents a Marathon HealthCheck.
# See https://mesosphere.github.io/marathon/docs/health-checks.html for full details.
class Marathon::HealthCheck

  DEFAULTS = {
    'gracePeriodSeconds' => 300,
    'intervalSeconds' => 60,
    'maxConsecutiveFailures' => 3,
    'path' => '/',
    'portIndex' => 0,
    'protocol' => 'HTTP',
    'timeoutSeconds' => 20
  }

  attr_reader :info

  # Create a new health check object.
  # ++hash++: Hash returned by API.
  def initialize(hash)
    raise Marathon::Error::ArgumentError, 'hash must be an Hash' unless hash.is_a?(Hash)
    @info = DEFAULTS.merge(hash)
    Marathon::Util.validate_choice('protocol', protocol, %[HTTP TCP COMMAND], false)
  end

  # Shortcuts for reaching attributes
  %w[ command gracePeriodSeconds intervalSeconds maxConsecutiveFailures
      path portIndex protocol timeoutSeconds ].each do |method|
    define_method(method) { |*args, &block| info[method] }
  end

  def to_s
    if protocol == 'COMMAND'
      "Marathon::HealthCheck { :protocol => #{protocol} :command => #{command} }"
    elsif protocol == 'HTTP'
      "Marathon::HealthCheck { :protocol => #{protocol} :portIndex => #{portIndex} :path => #{path} }"
    else
      "Marathon::HealthCheck { :protocol => #{protocol} :portIndex => #{portIndex} }"
    end
  end

  # Return deployment info as JSON formatted string.
  def to_json
    @info.to_json
  end
end