# This class represents a Marathon Event Subscriptions.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#event-subscriptions for full list of API's methods.
# DEPRECATED
class Marathon::EventSubscriptions

  class << self
    # List all event subscriber callback URLs.
    # Returns a list of strings/URLs.
    def list(conn = Marathon.connection)
      json = conn.get('/v2/eventSubscriptions')
      json['callbackUrls']
    end

    # Register a callback URL as an event subscriber.
    # ++callbackUrl++: URL to which events should be posted.
    # Returns an event as hash.
    def register(callbackUrl, conn = Marathon.connection)
      query = {}
      query[:callbackUrl] = callbackUrl
      json = conn.post('/v2/eventSubscriptions', query)
      json
    end

    # Unregister a callback URL from the event subscribers list.
    # ++callbackUrl++: URL passed when the event subscription was created.
    # Returns an event as hash.
    def unregister(callbackUrl, conn = Marathon.connection)
      query = {}
      query[:callbackUrl] = callbackUrl
      json = conn.delete('/v2/eventSubscriptions', query)
      json
    end
  end
end