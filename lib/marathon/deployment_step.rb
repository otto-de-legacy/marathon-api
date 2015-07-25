# This class represents a Marathon Deployment step.
class Marathon::DeploymentStep < Marathon::Base

  attr_reader :actions

  # Create a new deployment step object.
  # ++hash++: Hash returned by API, including 'actions'
  def initialize(hash, conn = Marathon.connection)
    super(hash, conn)
    if hash.is_a?(Array)
      @actions = info.map { |e| Marathon::DeploymentAction.new(e, connection) }
    else
      @actions = (info[:actions] || []).map { |e| Marathon::DeploymentAction.new(e, connection) }
    end
  end

  def to_s
    "Marathon::DeploymentStep { :actions => #{actions.map{|e| e.to_pretty_s}.join(',')} }"
  end

end
