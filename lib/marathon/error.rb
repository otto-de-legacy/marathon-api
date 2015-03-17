# This module holds the Errors for the gem.
module Marathon::Error
  # The default error. It's never actually raised, but can be used to catch all
  # gem-specific errors that are thrown as they all subclass from this.
  class MarathonError < StandardError; end

  # Raised when invalid arguments are passed to a method.
  class ArgumentError < MarathonError; end

  # Raised when a request returns a 400 or 422.
  class ClientError < MarathonError; end

  # Raised when a request returns a 404.
  class NotFoundError < MarathonError; end

  # Raised when there is an unexpected response code / body.
  class UnexpectedResponseError < MarathonError; end

  # Raised when a request times out.
  class TimeoutError < MarathonError; end

  # Raised when login fails.
  class AuthenticationError < MarathonError; end

  # Raised when an IO action fails.
  class IOError < MarathonError; end

  # Raise error specific to http response.
  # ++response++: HTTParty response object.
  def from_response(response)
    error_class(response).new(error_message(response))
  end

  private

  # Get reponse code specific error class.
  # ++response++: HTTParty response object.
  def error_class(response)
    case response.code
    when 400
      ClientError
    when 422
      ClientError
    when 404
      NotFoundError
    else
      UnexpectedResponseError
    end
  end

  # Get response code from http response.
  # ++response++: HTTParty response object.
  def error_message(response)
    body = response.parsed_response
    if not body.is_a?(Hash)
      body
    elsif body['message']
      body['message']
    elsif body['errors']
      body['errors']
    else
      body
    end
  end

  module_function :error_class, :error_message, :from_response

end
