# This class represents a Marathon Leader.
class Marathon::Leader

  class << self
    # Return a specific app.
    def get
      json = Marathon.connection.get('/leader')
      json['leader']
    end

    def delete
      json = Marathon.connection.delete('/leader')
      json['message']
    end
  end
end