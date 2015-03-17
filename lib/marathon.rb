require 'rubygems/package'
require 'httparty'
require 'json'
require 'uri'

# The top-level module for this gem. It's purpose is to hold global
# configuration variables that are used as defaults in other classes.
module Marathon

  attr_accessor :logger

  require 'marathon/version'
  require 'marathon/util'
  require 'marathon/error'
  require 'marathon/connection'
  require 'marathon/base'
  require 'marathon/constraint'
  require 'marathon/container_docker_port_mapping'
  require 'marathon/container_docker'
  require 'marathon/container_volume'
  require 'marathon/container'
  require 'marathon/health_check'
  require 'marathon/deployment_info'
  require 'marathon/deployment_action'
  require 'marathon/deployment_step'
  require 'marathon/group'
  require 'marathon/app'
  require 'marathon/deployment'
  require 'marathon/event_subscriptions'
  require 'marathon/leader'
  require 'marathon/queue'
  require 'marathon/task'

  DEFAULT_URL = 'http://localhost:8080'

  # Get the marathon url from environment
  def env_url
    ENV['MARATHON_URL']
  end

  # Get marathon options from environment
  def env_options
    opts = {}
    opts[:username] = ENV['MARATHON_USER'] if ENV['MARATHON_USER']
    opts[:password] = ENV['MARATHON_PASSWORD'] if ENV['MARATHON_PASSWORD']
    opts
  end

  # Get the marathon API URL
  def url
    @url ||= env_url || DEFAULT_URL
    @url
  end

  # Get options for connecting to marathon API
  def options
    @options ||= env_options
  end

  # Set a new url
  def url=(new_url)
    @url = new_url
    reset_connection!
  end

  # Set new options
  def options=(new_options)
    @options = env_options.merge(new_options || {})
    reset_connection!
  end

  # Set a new connection
  def connection
    @connection ||= Connection.new(url, options)
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

  module_function :connection, :env_options, :env_url, :info, :logger, :logger=, :ping,
                  :options, :options=, :url, :url= ,:reset_connection!

end
