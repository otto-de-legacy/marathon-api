# This class represents a Marathon API Connection.
class Marathon::Connection

  include Marathon::Error
  include HTTParty

  headers(
    'Content-Type' => 'application/json',
    'Accept' => 'application/json',
    'User-Agent' => "ub0r/Marathon-API #{Marathon::VERSION}"
  )

  default_timeout 5
  maintain_method_across_redirects

  attr_reader :url, :options

  # Create a new API connection.
  # ++url++: URL of the marathon API.
  # ++options++: Hash with options for marathon API.
  def initialize(url, options = {})
    @url = url
    @options = options
    if @options[:username] and @options[:password]
      @options[:basic_auth] = {
        :username => @options[:username],
        :password => @options[:password]
      }
      @options.delete(:username)
      @options.delete(:password)
    end
  end

  # Delegate all HTTP methods to the #request.
  [:get, :put, :post, :delete].each do |method|
    define_method(method) { |*args, &block| request(method, *args) }
  end

  def to_s
    "Marathon::Connection { :url => #{url} :options => #{options} }"
  end

private

  # Create URL suffix for a hash of query parameters.
  # URL escaping is done internally.
  # ++query++: Hash of query parameters.
  def query_params(query)
    query = query.select { |k,v| !v.nil? }
    URI.escape(query.map { |k,v| "#{k}=#{v}" }.join('&'))
  end

  # Create request object.
  # ++http_method++: GET/POST/PUT/DELETE.
  # ++path++: Relative path to connection's URL.
  # ++query++: Optional query parameters.
  # ++opts++: Optional options. Ex. opts[:body] is used for PUT/POST request.
  def compile_request_params(http_method, path, query = nil, opts = nil)
    query ||= {}
    opts ||= {}
    headers = opts.delete(:headers) || {}
    opts[:body] = opts[:body].to_json unless opts[:body].nil?
    {
      :method        => http_method,
      :url           => "#{@url}#{path}",
      :query         => query
    }.merge(opts).reject { |_, v| v.nil? }
  end

  # Create full URL with query parameters.
  # ++url++: Base URL.
  # ++query++: Hash of query parameters.
  def build_url(url, query)
    url = URI.escape(url)
    if query.size > 0
      url += '?' + query_params(query)
    end
    url
  end

  # Send a request to the server and parse response.
  # ++http_method++: GET/POST/PUT/DELETE.
  # ++path++: Relative path to connection's URL.
  # ++query++: Optional query parameters.
  # ++opts++: Optional options. Ex. opts[:body] is used for PUT/POST request.
  def request(*args)
    request = compile_request_params(*args)
    url = build_url(request[:url], request[:query])
    response = self.class.send(request[:method], url, request)
    if response.success?
      response.parsed_response
    else
      raise Marathon::Error.from_response(response)
    end
  rescue => e
    if e.class == SocketError or e.class.name.start_with?('Errno::')
      raise IOError, "HTTP call failed: #{e.message}"
    else
      raise e
    end
  end

end