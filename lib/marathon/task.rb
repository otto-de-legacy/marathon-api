# This class represents a Marathon Task.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/tasks for full list of API's methods.
class Marathon::Task < Marathon::Base

  ACCESSORS = %w[ id appId host ports servicePorts version stagedAt startedAt ]

  # Create a new task object.
  # ++hash++: Hash including all attributes
  def initialize(hash)
    super(hash, ACCESSORS)
  end

  # Kill the task that belongs to an application.
  # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
  #            after killing the specified tasks.
  def delete!(scale = false)
    new_task = self.class.delete(appId, id, scale)
    @info = new_task.info
  end
  alias :kill! :delete!

  def to_s
    "Marathon::Task { :id => #{self.id} :appId => #{appId} :host => #{host} }"
  end

  # Returns a string for listing the task.
  def to_pretty_s
    %Q[
Task ID:    #{id}
App ID:     #{appId}
Host:       #{host}
Ports:      #{(ports || []).join(',')}
Staged at:  #{stagedAt}
Started at: #{startedAt}
Version:    #{version}
    ].strip
  end

  class << self

    # List tasks of all applications.
    # ++status++: Return only those tasks whose status matches this parameter.
    #             If not specified, all tasks are returned. Possible values: running, staging.
    def list(status = nil)
      query = {}
      Marathon::Util.add_choice(query, :status, status, %w[running staging])
      json = Marathon.connection.get('/v2/tasks', query)['tasks']
      json.map { |j| new(j) }
    end

    # List all running tasks for application appId.
    # ++appId++: Application's id
    def get(appId)
      json = Marathon.connection.get("/v2/apps/#{appId}/tasks")['tasks']
      json.map { |j| new(j) }
    end

    # Kill the task that belongs to the application appId.
    # ++appId++: Application's id
    # ++id++: Id of target task.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete(appId, id, scale = false)
      query = {}
      query[:scale] = true if scale
      json = Marathon.connection.delete("/v2/apps/#{appId}/tasks/#{id}", query)
      new(json)
    end
    alias :remove :delete
    alias :kill :delete

    # Kill tasks that belong to the application appId.
    # ++appId++: Application's id
    # ++host++: Kill only those tasks running on host host.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete_all(appId, host = nil, scale = false)
      query = {}
      query[:host] = host if host
      query[:scale] = true if scale
      json = Marathon.connection.delete("/v2/apps/#{appId}/tasks", query)['tasks']
      json.map { |j| new(j) }
    end
    alias :remove_all :delete_all
    alias :kill_all :delete_all
  end

end