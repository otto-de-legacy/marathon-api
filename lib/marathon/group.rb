# This class represents a Marathon Group.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#groups for full list of API's methods.
class Marathon::Group < Marathon::Base

  ACCESSORS = %w[ id dependencies version ]

  DEFAULTS = {
    :apps => [],
    :dependencies => [],
    :groups => []
  }

  # Create a new group object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/groups for full details.
  def initialize(hash)
    super(Marathon::Util.merge_keywordized_hash(DEFAULTS, hash), ACCESSORS)
    raise ArgumentError, 'Group must have an id' unless id
    raise ArgumentError, 'Group can have either groups or apps, not both' if apps.size > 0 and groups.size > 0
  end

  # Get apps.
  # This is read only!
  def apps
    @info[:apps].map { |e| Marathon::App.new(e) }
  end

  # Get groups.
  # This is read only!
  def groups
    @info[:groups].map { |e| Marathon::Group.new(e) }
  end

  # Reload attributes from marathon API.
  def refresh
    new_app = self.class.get(id)
    @info = new_app.info
  end

  # Create and start a the application group. Application groups can contain other application groups.
  # An application group can either hold other groups or applications, but can not be mixed in one.
  # Since the deployment of the group can take a considerable amount of time,
  # this endpoint returns immediatly with a version. The failure or success of the action is signalled via event.
  # There is a group_change_success and group_change_failed event with the given version.
  def start!
    self.class.start(info)
  end

  # Change parameters of a deployed application group.
  # Changes to application parameters will result in a restart of this application.
  # A new application added to the group is started.
  # An existing application removed from the group gets stopped.
  # If there are no changes to the application definition, no restart is triggered.
  # During restart marathon keeps track, that the configured amount of minimal running instances are always available.
  # A deployment can run forever. This is the case, when the new application has a problem and does not become healthy.
  # In this case, human interaction is needed with 2 possible choices:
  # Rollback to an existing older version (send an existing version in the body)
  # Update with a newer version of the group which does not have the problems of the old one.
  # If there is an upgrade process already in progress, a new update will be rejected unless the force flag is set.
  # With the force flag given, a running upgrade is terminated and a new one is started.
  # Since the deployment of the group can take a considerable amount of time,
  # this endpoint returns immediatly with a version. The failure or success of the action is signalled via event.
  # There is a group_change_success and group_change_failed event with the given version.
  # ++hash++: Hash of attributes to change.
  # ++force++: If the group is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def change!(hash, force = false)
    self.class.change(id, hash, force)
  end

  # Create a new version with parameters of an old version.
  # Currently running tasks are restarted, while maintaining the minimumHealthCapacity.
  # ++version++: Version name of the old version.
  # ++force++: If the group is affected by a running deployment, then the update operation will fail.
  #            The current deployment can be overridden by setting the `force` query parameter.
  def roll_back!(version, force = false)
    change!({'version' => version}, force)
  end

  def to_s
    "Marathon::Group { :id => #{id} }"
  end

  # Returns a string for listing the group.
  def to_pretty_s
    %Q[
Group ID:   #{id}
#{pretty_array(apps)}
#{pretty_array(groups)}
Version:    #{version}
    ].gsub(/\n\n+/, "\n").strip
  end

  private

  def pretty_array(array)
    array.map { |e| e.to_pretty_s.split("\n").map { |e| "    #{e}" }}.join("\n")
  end

  class << self

    # List the group with the specified ID.
    # ++id++: Group's id.
    def get(id)
      json = Marathon.connection.get("/v2/groups/#{id}")
      new(json)
    end

    # List all groups.
    def list
      json = Marathon.connection.get('/v2/groups')
      new(json)
    end

    # Delete the application group with id.
    # ++id++: Group's id.
    # ++force++: If the group is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def delete(id, force = false)
      query = {}
      query[:force] = true if force
      Marathon.connection.delete("/v2/groups/#{id}", query)
    end
    alias :remove :delete

    # Create and start a new application group. Application groups can contain other application groups.
    # An application group can either hold other groups or applications, but can not be mixed in one.
    # Since the deployment of the group can take a considerable amount of time,
    # this endpoint returns immediatly with a version. The failure or success of the action is signalled via event.
    # There is a group_change_success and group_change_failed event with the given version.
    # ++hash++: Hash including all attributes
    #           see https://mesosphere.github.io/marathon/docs/rest-api.html#post-/v2/groups for full details
    def start(hash)
      json = Marathon.connection.post('/v2/groups', nil, :body => hash)
      Marathon::DeploymentInfo.new(json)
    end
    alias :create :start

    # Change parameters of a deployed application group.
    # Changes to application parameters will result in a restart of this application.
    # A new application added to the group is started.
    # An existing application removed from the group gets stopped.
    # If there are no changes to the application definition, no restart is triggered.
    # During restart marathon keeps track, that the configured amount of minimal running instances are always available.
    # A deployment can run forever. This is the case,
    # when the new application has a problem and does not become healthy.
    # In this case, human interaction is needed with 2 possible choices:
    # Rollback to an existing older version (send an existing version in the body)
    # Update with a newer version of the group which does not have the problems of the old one.
    # If there is an upgrade process already in progress, a new update will be rejected unless the force flag is set.
    # With the force flag given, a running upgrade is terminated and a new one is started.
    # Since the deployment of the group can take a considerable amount of time,
    # this endpoint returns immediatly with a version. The failure or success of the action is signalled via event.
    # There is a group_change_success and group_change_failed event with the given version.
    # ++id++: Group's id.
    # ++hash++: Hash of attributes to change.
    # ++force++: If the group is affected by a running deployment, then the update operation will fail.
    #            The current deployment can be overridden by setting the `force` query parameter.
    def change(id, hash, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.put("/v2/groups/#{id}", query, :body => hash)
      Marathon::DeploymentInfo.new(json)
    end
  end
end
