require 'rubygems/package'
require 'httparty'
require 'json'
require 'uri'

# The top-level module for this gem. It's purpose is to hold global
# configuration variables that are used as defaults in other classes.
module Marathon

  attr_accessor :logger

  require 'marathon/error'
  require 'marathon/connection'
  require 'marathon/app'
  require 'marathon/leader'
  require 'marathon/task'
  require 'marathon/version'

  DEFAULT_URL = 'http://localhost:8080'

  # Get the marathon url from environment
  def env_url
    ENV['MARATHON_URL']
  end

  # Get the marathon url
  def url
    @url ||= env_url || DEFAULT_URL
    @url
  end

  # Set a new url
  def url=(new_url)
    @url = new_url
    reset_connection!
  end

  # Set a new connection
  def connection
    @connection ||= Connection.new(url)
  end

  # Reset the connection
  def reset_connection!
    @connection = nil
  end

  # Get information about the marathon server
  def info
    connection.get('/v2/info')
  end

  # Ping marathon
  def ping
    connection.get('/ping')
  end

  module_function :connection, :env_url, :info, :logger, :logger=,
                  :ping, :url, :url= ,:reset_connection!

end
