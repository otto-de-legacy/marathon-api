# This class represents a Marathon App.
class Marathon::App

  attr_reader :info

  # Create a new app.
  # ++hash++: Hash including all attributes
  def initialize(hash = {})
    @info = hash
  end

  # Shortcuts for reaching attributes
  %w[ id args cmd cpus disk env executor instances mem ports requirePorts
      storeUris tasksRunning tasksStaged uris user version ].each do |method|
    define_method(method) { |*args, &block| info[method] }
  end

  # Get list of tasks
  def tasks
    unless @info['tasks']
      refresh
    end

    raise Marathon::Error::UnexpectedResponseError, "Expected to find tasks element in app's info" unless @info['tasks']

    @info['tasks'].map { |e| Marathon::Task.new(e) }
  end

  # Reload attributes from marathon API
  def refresh
    new_app = self.class.get(id)
    @info = new_app.info
  end

  # Create and start the application
  def start!
    new_app = self.class.start(info)
    @info = new_app.info
  end

  # Restart all instances of the application
  def restart!(force = false)
    self.class.restart(id, force)
  end

  # Change the application.
  def change!(hash, force = false)
    self.class.change(id, hash, force)
  end

  # Scales the number of instances of an application.
  def scale!(instances, force = false)
    change!({'instances' => instances}, force)
  end

  # Scales the number of instances of an application down to 0.
  def suspend!(force = false)
    scale!(0, force)
  end

  def to_s
    "Marathon::App { :id => #{self.id} }"
  end

  # Get app as json formatted string.
  def to_json
    info.to_json
  end

  class << self

    # List the application with id.
    def get(id)
      json = Marathon.connection.get("/v2/apps/#{id}")['app']
      new(json)
    end

    # List all apps.
    # ++:cmd++: Filter apps to only those whose commands contain cmd.
    # ++:embed++: Embeds nested resources that match the supplied path.
    #             Possible values:
    #               "apps.tasks". Apps' tasks are not embedded in the response by default.
    #               "apps.failures". Apps' last failures are not embedded in the response by default.
    def list(cmd = nil, embed = nil)
      query = {}
      query[:cmd] = cmd if cmd
      Marathon::Util.add_choice(query, :embed, embed, %w[apps.tasks apps.failures])
      json = Marathon.connection.get('/v2/apps', query)['apps']
      json.map { |j| new(j) }
    end

    # Delete the application with id.
    def delete(id)
      Marathon.connection.delete("/v2/apps/#{id}")
    end
    alias :remove :delete

    # Create and start an application.
    def start(hash)
      json = Marathon.connection.post('/v2/apps', nil, :body => hash)
      new(json)
    end
    alias :create :start

    # Restart the application with id.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def restart(id, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.post("/v2/apps/#{id}/restart", query)
      # TODO parse deploymentId + version
    end

    # Change parameters of a running application. The new application parameters apply only to subsequently
    # created tasks. Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
    # ++hash++: A subset of app's attributes.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def change(id, hash, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.put("/v2/apps/#{id}", query, :body => hash)
      # TODO parse deploymentId + version
    end
  end
end