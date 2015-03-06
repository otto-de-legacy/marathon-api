# This class represents a Marathon Leader.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/leader for full list of API's methods.
class Marathon::Leader

  class << self
    # Returns the current leader. If no leader exists, raises NotFoundError.
    def get
      json = Marathon.connection.get('/v2/leader')
      json['leader']
    end

    # Causes the current leader to abdicate, triggering a new election.
    # If no leader exists, raises NotFoundError.
    def delete
      json = Marathon.connection.delete('/v2/leader')
      json['message']
    end
  end
end