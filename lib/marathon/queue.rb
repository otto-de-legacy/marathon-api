# This class represents a Marathon Task.
class Marathon::Queue

  attr_reader :app
  attr_reader :delay

  # Create a new queue element.
  # ++hash++: Hash including 'app' and 'delay'
  def initialize(hash = {})
    @app = Marathon::App.new(hash['app'], true)
    @delay = hash['delay']
  end

  def to_s
    "Marathon::Queue { :appId => #{app.id} :delay => #{delay} }"
  end

  # Get queue as json formatted string.
  def to_json
    {
      'app' => @app.info,
      'delay' => @delay
    }.to_json
  end

  class << self

    # Show content of the task queue.
    def list
      json = Marathon.connection.get('/v2/queue')['queue']
      json.map { |j| new(j) }
    end
  end
end