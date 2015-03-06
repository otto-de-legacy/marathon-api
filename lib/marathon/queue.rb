# This class represents a Marathon Queue element.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#queue for full list of API's methods.
class Marathon::Queue

  attr_reader :app
  attr_reader :delay

  # Create a new queue element object.
  # ++hash++: Hash returned by API, including 'app' and 'delay'
  def initialize(hash = {})
    @app = Marathon::App.new(hash['app'], true)
    @delay = hash['delay']
  end

  def to_s
    "Marathon::Queue { :appId => #{app.id} :delay => #{delay} }"
  end

  # Return queue element as JSON formatted string.
  def to_json
    {
      'app' => @app.info,
      'delay' => @delay
    }.to_json
  end

  class << self

    # Show content of the task queue.
    # Returns Array of Queue objects.
    def list
      json = Marathon.connection.get('/v2/queue')['queue']
      json.map { |j| new(j) }
    end
  end
end