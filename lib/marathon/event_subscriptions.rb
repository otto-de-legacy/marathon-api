# This class represents a Marathon Event Subscriptions.
class Marathon::EventSubscriptions

  class << self
    # List all event subscriber callback URLs..
    def list
      json = Marathon.connection.get('/v2/eventSubscriptions')
      json['callbackUrls']
    end

    # Register a callback URL as an event subscriber.
    # ++callbackUrl++: URL to which events should be posted.
    def register(callbackUrl)
      query = {}
      query[:callbackUrl] = callbackUrl
      json = Marathon.connection.post('/v2/eventSubscriptions', query)
      json
    end

    # Unregister a callback URL from the event subscribers list.
    # ++callbackUrl++: URL passed when the event subscription was created.
    def unregister(callbackUrl)
      query = {}
      query[:callbackUrl] = callbackUrl
      json = Marathon.connection.delete('/v2/eventSubscriptions', query)
      json
    end
  end
end