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
  require 'marathon/util'
  require 'marathon/version'

  DEFAULT_URL = 'http://localhost:8080'

  def env_url
    ENV['MARATHON_URL']
  end

  def url
    @url ||= env_url || DEFAULT_URL
    @url
  end

  def url=(new_url)
    @url = new_url
  end

  def connection
    @connection ||= Connection.new(url)
  end

  def reset_connection!
    @connection = nil
  end

  def info
    connection.get("/info")
  end

  module_function :connection, :env_url, :info, :logger, :logger=,
                  :url, :url= ,:reset_connection!

end
