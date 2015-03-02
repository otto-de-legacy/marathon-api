# This class represents a Marathon Task.
class Marathon::Task

  attr_reader :json

  # Create a new task
  def initialize(json)
    @json = json
  end

  # Shortcuts for reaching attributes
  %w[ id appId host ports servicePorts version stagedAt startedAt ].each do |method|
    define_method(method) { |*args, &block| json[method] }
  end

  # Delete the task
  # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
  #            after killing the specified tasks.
  def delete!(scale = false)
    new_task = self.class.delete(appId, id, scale)
    @json = new_task.json
  end

  def to_s
    "Marathon::Task { :id => #{self.id} :appId => #{appId} :host => #{host} }"
  end

  class << self

    # List all tasks.
    # ++status++: Return only those tasks whose status matches this parameter.
    #             If not specified, all tasks are returned. Possible values: running, staging.
    def list(status = nil)
      opts = {}
      if status
        if status != 'running' and status != 'staging'
          raise Marathon::Error::ArgumentError, 'status must be nil, running or staging'
        end
        opts[:status] = status
      end
      json = Marathon.connection.get('/v2/tasks', opts)['tasks']
      json.map { |j| new(j) }
    end

    # Get tasks of an app.
    # ++appId++: Id of tasks' app.
    def get(appId)
      json = Marathon.connection.get("/v2/apps/#{appId}/tasks")['tasks']
      json.map { |j| new(j) }
    end

    # Delete a task.
    # ++appId++: Id of tasks' app.
    # ++id++: Id of target task.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete(appId, id, scale = false)
      opts = {}
      opts[:scale] = scale if scale
      json = Marathon.connection.delete("/v2/apps/#{appId}/tasks/#{id}", opts)
      new(json)
    end
    alias :remove :delete

    # Delete all tasks of an app.
    # ++appId++: Id of tasks' app.
    # ++host++: Kill only those tasks running on host host.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete_all(appId, host = nil, scale = false)
      opts = {}
      opts[:host] = host if host
      opts[:scale] = scale if scale
      json = Marathon.connection.delete("/v2/apps/#{appId}/tasks", opts)['tasks']
      json.map { |j| new(j) }
    end
    alias :remove_all :delete_all
  end

end