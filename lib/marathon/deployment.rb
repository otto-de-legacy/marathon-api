# This class represents a Marathon Deployment.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#deployments for full list of API's methods.
class Marathon::Deployment

  attr_reader :info

  # Create a new deployment object.
  # ++hash++: Hash including all attributes.
  #           See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/deployments for full details.
  def initialize(hash = {})
    @info = hash
  end

  # Shortcuts for reaching attributes
  %w[ id affectedApps steps currentActions version currentStep totalSteps ].each do |method|
    define_method(method) { |*args, &block| info[method] }
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

  # Return deployment as JSON formatted string.
  def to_json
    info.to_json
  end

  class << self

    # List running deployments.
    def list
      json = Marathon.connection.get('/v2/deployments')
      json.map { |j| new(j) }
    end

    # Cancel the deployment with id.
    # ++id++: Deployment's id
    # ++force++: If set to false (the default) then the deployment is canceled and a new deployment
    #            is created to restore the previous configuration. If set to true, then the deployment
    #            is still canceled but no rollback deployment is created.
    def delete(id, force = false)
      query = {}
      query[:force] = true if force
      json = Marathon.connection.delete("/v2/deployments/#{id}")
      # TODO parse deploymentId + version
    end
    alias :cancel :delete
    alias :remove :delete
  end
end