# This class represents a Marathon App.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#apps for full list of API's methods.
class Marathon::App < Marathon::Base

  ACCESSORS = %w[ id args cmd cpus disk env executor instances mem ports requirePorts
                  storeUris tasksHealthy tasksUnhealthy tasksRunning tasksStaged upgradeStrategy
                  uris user version labels ]

  DEFAULTS = {
    :env => {},
    :ports => [],
    :uris => []
  }

  attr_reader :healthChecks, :constraints, :container, :read_only, :tasks

  # Create a new application object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/apps for full details.
  # ++read_only++: prevent actions on this application
  def initialize(hash, read_only = false)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    raise ArgumentError, 'App must have an id' unless id
    @read_only = read_only
    refresh_attributes
  end

  # Prevent actions on read only instances.
  # Raises an ArgumentError when triying to change read_only instances.
  def check_read_only
    if read_only
      raise Marathon::Error::ArgumentError, "This app is 'read only' and does not support any actions"
    end
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
    refresh_attributes
    self
  end

  # Create and start the application.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def start!(force = false)
    change!(info, force)
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
    Marathon::Util.keywordize_hash!(hash)
    if hash[:version] and hash.size > 1
      # remove :version if it's not the only key
      new_hash = Marathon::Util.remove_keys(hash, [:version])
    else
      new_hash = hash
    end
    self.class.change(id, new_hash, force)
  end

  # Create a new version with parameters of an old version.
  # Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
  # ++version++: Version name of the old version.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def roll_back!(version, force = false)
    change!({:version => version}, force)
  end

  # Change the number of desired instances.
  # ++instances++: Number of running instances.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def scale!(instances, force = false)
    change!({:instances => instances}, force)
  end

  # Change the number of desired instances to 0.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def suspend!(force = false)
    scale!(0, force)
  end

  def to_s
    "Marathon::App { :id => #{id} }"
  end

  # Returns a string for listing the application.
  def to_pretty_s
    %Q[
App ID:     #{id}
Instances:  #{tasks.size}/#{instances}
Command:    #{cmd}
CPUs:       #{cpus}
Memory:     #{mem} MB
#{pretty_container}
#{pretty_uris}
#{pretty_env}
#{pretty_constraints}
Version:    #{version}
    ].gsub(/\n\n+/, "\n").strip
  end

  private

  def pretty_container
    if container and container.docker
      "Docker:     #{container.docker.to_pretty_s}"
    end
  end

  def pretty_env
    env.map { |k,v| "ENV:        #{k}=#{v}" }.join("\n")
  end

  def pretty_uris
    uris.map { |e| "URI:        #{e}" }.join("\n")
  end

  def pretty_constraints
    constraints.map { |e| "Constraint: #{e.to_pretty_s}" }.join("\n")
  end

  # Rebuild attribute classes
  def refresh_attributes
    @healthChecks = (info[:healthChecks] || []).map { |e| Marathon::HealthCheck.new(e) }
    @constraints = (info[:constraints] || []).map { |e| Marathon::Constraint.new(e) }
    if info[:container]
      @container = Marathon::Container.new(info[:container])
    else
      @container = nil
    end
    @tasks = (@info[:tasks] || []).map { |e| Marathon::Task.new(e) }
  end

  class << self

    # List the application with id.
    # ++id++: Application's id.
    def get(id)
      Marathon.singleton.apps.get(id)
    end

    # List all applications.
    # ++:cmd++: Filter apps to only those whose commands contain cmd.
    # ++:embed++: Embeds nested resources that match the supplied path.
    #             Possible values:
    #               "apps.tasks". Apps' tasks are not embedded in the response by default.
    #               "apps.failures". Apps' last failures are not embedded in the response by default.
    def list(cmd = nil, embed = nil)
      Marathon.singleton.apps.list(cmd,embed)
    end

    # Delete the application with id.
    # ++id++: Application's id.
    def delete(id)
      Marathon.singleton.apps.delete(id)
    end
    alias :remove :delete

    # Create and start an application.
    # ++hash++: Hash including all attributes
    #           see https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/apps for full details
    def start(hash)
      Marathon.singleton.apps.start(hash)
    end
    alias :create :start

    # Restart the application with id.
    # ++id++: Application's id.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def restart(id, force = false)
      Marathon.singleton.apps.restart(id,force)
    end

    # Change parameters of a running application. The new application parameters apply only to subsequently
    # created tasks. Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
    # ++id++: Application's id.
    # ++hash++: A subset of app's attributes.
    # ++force++: If the app is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def change(id, hash, force = false)
      Marathon.singleton.apps.change(id,hash,force)
    end

    # List the versions of the application with id.
    # ++id++: Application id
    def versions(id)
      Marathon.singleton.apps.versions(id)
    end

    # List the configuration of the application with id at version.
    # ++id++: Application id
    # ++version++: Version name
    def version(id, version)
      Marathon.singleton.apps.version(id,version)
    end
  end
end

# This class represents a set of Apps
class Marathon::Apps
  def initialize(connection)
    @connection = connection
  end

  # List the application with id.
  # ++id++: Application's id.
  def get(id)
    json = @connection.get("/v2/apps/#{id}")['app']
    Marathon::App.new(json)
  end

  # Delete the application with id.
  # ++id++: Application's id.
  def delete(id)
    json = @connection.delete("/v2/apps/#{id}")
    Marathon::DeploymentInfo.new(json)
  end

  # Create and start an application.
  # ++hash++: Hash including all attributes
  #           see https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/apps for full details
  def start(hash)
    json = @connection.post('/v2/apps', nil, :body => hash)
    Marathon::App.new(json)
  end

  # Restart the application with id.
  # ++id++: Application's id.
  # ++force++: If the app is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def restart(id, force = false)
    query = {}
    query[:force] = true if force
    json = @connection.post("/v2/apps/#{id}/restart", query)
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
    json = @connection.put("/v2/apps/#{id}", query, :body => hash.merge(:id => id))
    Marathon::DeploymentInfo.new(json)
  end

  # List the versions of the application with id.
  # ++id++: Application id
  def versions(id)
    json = @connection.get("/v2/apps/#{id}/versions")
    json['versions']
  end

  # List the configuration of the application with id at version.
  # ++id++: Application id
  # ++version++: Version name
  def version(id, version)
    json = @connection.get("/v2/apps/#{id}/versions/#{version}")
    Marathon::App.new(json, true)
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
    json = @connection.get('/v2/apps', query)['apps']
    json.map { |j| Marathon::App.new(j) }
  end

end