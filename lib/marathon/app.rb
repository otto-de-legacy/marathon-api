# This class represents a Marathon App.
class Marathon::App

  attr_reader :json

  # Create a new app
  def initialize(json)
    @json = json
  end

  # Shortcuts for reaching attributes
  %w[ id args cmd cpus disk env executor instances mem ports requirePorts
      storeUris tasksRunning tasksStaged uris user version ].each do |method|
    define_method(method) { |*args, &block| json[method] }
  end

  # Get list of tasks
  def tasks
    unless @json['tasks']
      refresh!
    end

    raise Marathon::Error::UnexpectedResponseError, "Expected to find tasks element in app's json" unless @json['tasks']

    @json['tasks'].map { |e| Marathon::Task.new(e) }
  end

  # Reload attributes from marathon API
  def refresh!
    new_app = self.class.get(id)
    @json = new_app.json
  end

  # Create and start the application
  def start!
    new_app = self.class.start(json)
    @json = new_app.json
  end

  # Restart all instances of the application
  def restart!(force = false)
    self.class.restart(id, {:force => force})
  end

  def to_s
    "Marathon::App { :id => #{self.id} }"
  end

  # Get app as json formatted string.
  def to_json
    json.to_json
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