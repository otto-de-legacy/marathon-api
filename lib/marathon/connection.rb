# This class represents a Marathon API Connection.
class Marathon::Connection

  include Marathon::Error
  include HTTParty

  headers(
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  )

  default_timeout 5
  maintain_method_across_redirects

  attr_reader :url

  def initialize(url)
    @url = url
  end

  # Delegate all HTTP methods to the #request.
  [:get, :put, :post, :delete].each do |method|
    define_method(method) { |*args, &block| request(method, *args) }
  end

  def to_s
    "Marathon::Connection { :url => #{url} }"
  end

private

  def query_params(query)
    query = query.select { |k,v| !v.nil? }
    URI.escape(query.map { |k,v| "#{k}=#{v}" }.join('&'))
  end

  # Given an HTTP method, path, optional query
  def compile_request_params(http_method, path, query = nil, opts = nil)
    query ||= {}
    opts ||= {}
    headers = opts.delete(:headers) || {}
    opts[:body] = opts[:body].to_json unless opts[:body].nil?
    {
      :method        => http_method,
      :url           => "#{@url}/v2#{path}",
      :query         => query
    }.merge(opts).reject { |_, v| v.nil? }
  end

  def build_url(url, query)
    url = URI.escape(url)
    if query.size > 0
      url += '?' + query_params(request[:query])
    end
    url
  end

  # Send a request to the server
  def request(*args)
    request = compile_request_params(*args)
    url = build_url(request[:url], request[:query])
    http = self.class.send(request[:method], url, request)
    json = JSON.parse(http.body)
    if http.success?
      return json
    else
      raise Marathon::Error.from_response(http)
    end
  rescue MarathonError => e
    raise e
  rescue SystemCallError => e
    if e.class.name.start_with?('Errno::')
      raise IOError, "HTTP call failed: #{e.message}"
    else
      raise e
    end
  end

end