# This class represents a Marathon Deployment.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#deployments for full list of API's methods.
class Marathon::Deployment < Marathon::Base

  ACCESSORS = %w[ id affectedApps version currentStep totalSteps ]
  attr_reader :steps, :currentActions

  # Create a new deployment object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/deployments for full details.
  def initialize(hash)
    super(hash, ACCESSORS)
    @currentActions = (info[:currentActions] || []).map { |e| Marathon::DeploymentAction.new(e) }
    @steps = (info[:steps] || []).map { |e| Marathon::DeploymentStep.new(e) }
  end

  # Cancel the deployment.
  # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
  #            is created to restore the previous configuration. If set to true, then the deployment
  #            is still canceled but no rollback deployment is created.
  def delete(force = false)
    self.class.delete(id, force)
  end
  alias :cancel :delete

  def to_s
    "Marathon::Deployment { " \
      + ":id => #{id} :affectedApps => #{affectedApps} :currentStep => #{currentStep} :totalSteps => #{totalSteps} }"
  end

  class << self

    # List running deployments.
    def list
      Marathon.singleton.deployments.list
    end

    # Cancel the deployment with id.
    # ++id++: Deployment's id
    # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
    #            is created to restore the previous configuration. If set to true, then the deployment
    #            is still canceled but no rollback deployment is created.
    def delete(id, force = false)
      Marathon.singleton.deployments.delete(id,force)
    end
    alias :cancel :delete
    alias :remove :delete
  end
end

# This class represents a set of Deployments
class Marathon::Deployments
  def initialize(connection)
    @connection = connection
  end
  # List running deployments.
  def list
    json = @connection.get('/v2/deployments')
    json.map { |j| Marathon::Deployment.new(j) }
  end

  # Cancel the deployment with id.
  # ++id++: Deployment's id
  # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
  #            is created to restore the previous configuration. If set to true, then the deployment
  #            is still canceled but no rollback deployment is created.
  def delete(id, force = false)
    query = {}
    query[:force] = true if force
    json = @connection.delete("/v2/deployments/#{id}")
    Marathon::DeploymentInfo.new(json)
  end

end