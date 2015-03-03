# This class represents a Marathon Leader.
class Marathon::Leader

  class << self
    # Get current leader.
    def get
      json = Marathon.connection.get('/v2/leader')
      json['leader']
    end

    # Force voting a new leader.
    def delete
      json = Marathon.connection.delete('/v2/leader')
      json['message']
    end
  end
end