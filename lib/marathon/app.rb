# This class represents a Marathon App.
class Marathon::App

  attr_reader :json

  # Create a new app
  def initialize(json)
    @json = json
  end

  # Shortcuts for reaching attributes
  %w[ id env instances cpus mem ].each do |method|
    define_method(method) { |*args, &block| json[method] }
  end

  def start!
    new_app = self.class.start(json)
    @json = new_app.json
  end

  def refresh!
    new_app = self.class.get(id)
    @json = new_app.json
  end

  def restart!(force = false)
    self.class.restart(id, {:force => force})
  end

  def to_s
    "Marathon::App { :id => #{self.id} }"
  end

  class << self

    # List the application with id.
    def get(id)
      json = Marathon.connection.get("/v2/apps/#{id}")['app']
      new(json)
    end

    # List all apps
    # Valid options are:
    # ++:cmd++: string - Filter apps to only those whose commands contain cmd. Default: "".
    # ++:embed++: string - Embeds nested resources that match the supplied path. Default: none. Possible values:
    #                      "apps.tasks". Apps' tasks are not embedded in the response by default.
    #                      "apps.failures". Apps' last failures are not embedded in the response by default.
    def list(opts = {})
      json = Marathon.connection.get('/v2/apps', opts)['apps']
      json.map { |j| new(j) }
    end

    # Delete the application with id.
    def delete(id)
      Marathon.connection.delete("/v2/apps/#{id}")
    end
    alias :remove :delete

    # Create and start an application.
    def start(json)
      json = Marathon.connection.post('/v2/apps', nil, :body => json)
      new(json)
    end
    alias :create :start

    # Restart the application with id.
    # Valid options are:
    # ++:force++ => true|false
    def restart(id, opts = {})
      json = Marathon.connection.post("/v2/apps/#{id}/restart", opts)
      # TODO parse deploymentId + version
    end
  end
end