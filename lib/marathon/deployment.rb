# This class represents a Marathon Deployment.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#deployments for full list of API's methods.
class Marathon::Deployment < Marathon::Base

  ACCESSORS = %w[ id affectedApps version currentStep totalSteps ]
  attr_reader :steps, :currentActions

  # Create a new deployment object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/deployments for full details.
  def initialize(hash, conn = Marathon.connection)
    super(hash, conn, ACCESSORS)
    @currentActions = (info[:currentActions] || []).map { |e| Marathon::DeploymentAction.new(e, conn) }
    @steps = (info[:steps] || []).map { |e| Marathon::DeploymentStep.new(e, conn) }
  end

  # Cancel the deployment.
  # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
  #            is created to restore the previous configuration. If set to true, then the deployment
  #            is still canceled but no rollback deployment is created.
  def delete(force = false)
    self.class.delete(id, force, connection)
  end
  alias :cancel :delete

  def to_s
    "Marathon::Deployment { " \
      + ":id => #{id} :affectedApps => #{affectedApps} :currentStep => #{currentStep} :totalSteps => #{totalSteps} }"
  end

  class << self

    # List running deployments.
    def list(conn = Marathon.connection)
      json = conn.get('/v2/deployments')
      json.map { |j| new(j, conn) }
    end

    # Cancel the deployment with id.
    # ++id++: Deployment's id
    # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
    #            is created to restore the previous configuration. If set to true, then the deployment
    #            is still canceled but no rollback deployment is created.
    def delete(id, force = false, conn = Marathon.connection)
      query = {}
      query[:force] = true if force
      json = conn.delete("/v2/deployments/#{id}")
      Marathon::DeploymentInfo.new(json, conn)
    end
    alias :cancel :delete
    alias :remove :delete
  end
end
