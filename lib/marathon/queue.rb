# This class represents a Marathon Queue element.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#queue for full list of API's methods.
class Marathon::Queue < Marathon::Base

  attr_reader :app

  # Create a new queue element object.
  # ++hash++: Hash returned by API, including 'app' and 'delay'
  def initialize(hash, conn = Marathon.connection)
    super(hash, conn, %w[delay])
    @app = Marathon::App.new(info[:app], true, conn)
  end

  def to_s
    "Marathon::Queue { :appId => #{app.id} :delay => #{delay} }"
  end

  class << self

    # Show content of the task queue.
    # Returns Array of Queue objects.
    def list(conn = Marathon.connection)
      json = conn.get('/v2/queue')['queue']
      json.map { |j| new(j, conn) }
    end
  end
end