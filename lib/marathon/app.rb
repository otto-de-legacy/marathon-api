# This class represents a Marathon App.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#apps for full list of API's methods.
class Marathon::App < Marathon::Base

  ACCESSORS = %w[ id args cmd cpus disk env executor instances mem ports requirePorts
                  storeUris tasksRunning tasksStaged uris user version ]

  DEFAULTS = {
    :constraints => [],
    :env => {},
    :ports => [],
    :storeUris => []
  }

  attr_reader :read_only

  # Create a new application object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/apps for full details.
  # ++read_only++: prevent actions on this application
  def initialize(hash, read_only = false)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    raise ArgumentError, 'App must have an id' unless id
    @read_only = read_only
  end

  # Prevent actions on read only instances.
  # Raises an ArgumentError when triying to change read_only instances.
  def check_read_only
    if read_only
      raise Marathon::Error::ArgumentError, "This app is 'read only' and does not support any actions"
    end
  end

  # Get container info.
  # This is read only!
  def container
    if @info[:container]
      Marathon::Container.new(@info[:container])
    else
      nil
    end
  end

  # Get constrains.
  # This is read only!
  def constraints
    @info[:constraints].map { |e| Marathon::Constraint.new(e) }
  end

  # Get health checks.
  # This is read only!
  def healthChecks
    @info[:healthChecks].map { |e| Marathon::HealthCheck.new(e) }
  end

  # List all running tasks for the application.
  # This is read only!
  def tasks
    check_read_only
    unless @info[:tasks]
      refresh
    end

    raise UnexpectedResponseError, "Expected to find tasks element in app's info" unless @info[:tasks]
    @info[:tasks].map { |e| Marathon::Task.new(e) }
  end

  # List the versions of the application.
  # ++version++: Get a specific versions
  # Returns Array of Strings if ++version = nil++,
  # else returns Hash with version information.
  def versions(version = nil)
    if version
      self.class.version(id, version)
    else
      self.class.versions(id)
    end
  end

  # Reload attributes from marathon API.
  def refresh
    check_read_only
    new_app = self.class.get(id)
    @info = new_app.info
  end

  # Create and start the application.
  def start!
    check_read_only
    new_app = self.class.start(info)
    @info = new_app.info
  end

  # Initiates a rolling restart of all running tasks of the given app.
  # This call respects the configured minimumHealthCapacity.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def restart!(force = false)
    check_read_only
    self.class.restart(id, force)
  end

  # Change parameters of a running application.
  # The new application parameters apply only to subsequently created tasks.
  # Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
  # ++hash++: Hash of attributes to change.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def change!(hash, force = false)
    check_read_only
    self.class.change(id, hash, force)
  end

  # Create a new version with parameters of an old version.
  # Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
  # ++version++: Version name of the old version.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def roll_back!(version, force = false)
    change!({'version' => version}, force)
  end

  # Change the number of desired instances.
  # ++instances++: Number of running instances.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def scale!(instances, force = false)
    change!({'instances' => instances}, force)
  end

  # Change the number of desired instances to 0.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def suspend!(force = false)
    scale!(0, force)
  end

  def to_s
    "Marathon::App { :id => #{self.id} }"
  end

  # Returns a string for listing the application.
  def to_pretty_s
    s =  "App ID:     #{id}\n"
    s += "Instances:  #{tasks.size}/#{instances}\n"
    s += "Command:    #{cmd}\n"
    s += "CPUs:       #{cpus}\n"
    s += "Memory:     #{mem} MB\n"
    (uris || []).each do |uri|
      s += "URI:        #{uri}\n"
    end
    (env || []).each do |k, v|
      s += "ENV:        #{k}=#{v}\n"
    end
    constraints.each do |constraint|
      s += "Constraint: #{constraint.to_pretty_s}\n"
    end
    s += "Version:    #{version}\n"
    s
  end

  class << self

    # List the application with id.
    # ++id++: Application's id.
    def get(id)
      json = Marathon.connection.get("/v2/apps/#{id}")['app']
      new(json)
    end

    # List all applications.
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
    # ++id++: Application's id.
    def delete(id)
      Marathon.connection.delete("/v2/apps/#{id}")
    end
    alias :remove :delete

    # Create and start an application.
    # ++hash++: Hash including all attributes
    #           see https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/apps for full details
    def start(hash)
      json = Marathon.connection.post('/v2/apps', nil, :body => hash)
      new(json)
    end
    alias :create :start

    # Restart the application with id.
    # ++id++: Application's id.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def restart(id, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.post("/v2/apps/#{id}/restart", query)
      Marathon::DeploymentInfo.new(json)
    end

    # Change parameters of a running application. The new application parameters apply only to subsequently
    # created tasks. Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
    # ++id++: Application's id.
    # ++hash++: A subset of app's attributes.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def change(id, hash, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.put("/v2/apps/#{id}", query, :body => hash)
      Marathon::DeploymentInfo.new(json)
    end

    # List the versions of the application with id.
    # ++id++: Application id
    def versions(id)
      json = Marathon.connection.get("/v2/apps/#{id}/versions")
      json['versions']
    end

    # List the configuration of the application with id at version.
    # ++id++: Application id
    # ++version++: Version name
    def version(id, version)
      json = Marathon.connection.get("/v2/apps/#{id}/versions/#{version}")
      new(json, true)
    end
  end
end