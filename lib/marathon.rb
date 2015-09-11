require 'rubygems/package'
require 'httparty'
require 'json'
require 'uri'
require 'timeout'

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

  # Represents an instance of Marathon
  class MarathonInstance
    attr_reader :connection

    def initialize(url, options)
      @connection = Connection.new(url,options)
    end

    def ping
      connection.get('/ping')
    end

    # Get information about the marathon server
    def info
      connection.get('/v2/info')
    end

    def apps
      Marathon::Apps.new(connection)
    end

    def deployments
      Marathon::Deployments.new(connection)
    end

    def tasks
      Marathon::Tasks.new(connection)
    end

    def queues
      Marathon::Queues.new(connection)
    end

    def leaders
      Marathon::Leader.new(connection)
    end

    def event_subscriptions
      Marathon::EventSubscriptions.new(connection)
    end

  end


  DEFAULT_URL = 'http://localhost:8080'

  attr_reader :singleton

  @singleton = MarathonInstance::new(DEFAULT_URL,{})

  # Get the marathon url from environment
  def env_url
    ENV['MARATHON_URL']
  end

  # Get marathon options from environment
  def add_env_options(opts)
    opts[:username] ||= ENV['MARATHON_USER'] if ENV['MARATHON_USER']
    opts[:password] ||= ENV['MARATHON_PASSWORD'] if ENV['MARATHON_PASSWORD']
    opts[:insecure] ||= ENV['MARATHON_INSECURE'] == 'true' if ENV['MARATHON_INSECURE']
    opts
  end

  # Get the marathon API URL
  def url
    @url ||= env_url || DEFAULT_URL
    @url
  end

  # Get options for connecting to marathon API
  def options
    @options ||= {}
  end

  # Set a new url
  def url=(new_url)
    @url = new_url
    reset_singleton!
  end

  # Set new options
  def options=(new_options)
    @options = add_env_options(new_options)
    reset_singleton!
  end

  # Set a new connection
  def connection
    singleton.connection
  end


  def reset_singleton!
    @singleton = MarathonInstance.new(url,options)
  end

  def reset_connection!
    reset_singleton!
  end

  # Get information about the marathon server
  def info
    singleton.info
  end

  # Ping marathon
  def ping
    singleton.ping
  end

  module_function :connection, :add_env_options, :env_url, :info, :logger, :logger=, :ping,
                  :options, :options=, :url, :url= ,:reset_connection!,:reset_singleton!,:singleton


end
