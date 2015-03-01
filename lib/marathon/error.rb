# This module holds the Errors for the gem.
module Marathon::Error
  # The default error. It's never actually raised, but can be used to catch all
  # gem-specific errors that are thrown as they all subclass from this.
  class MarathonError < StandardError; end

  # Raised when invalid arguments are passed to a method.
  class ArgumentError < MarathonError; end

  # Raised when a request returns a 400.
  class ClientError < MarathonError; end

  # Raised when a request returns a 401.
  class UnauthorizedError < MarathonError; end

  # Raised when a request returns a 404.
  class NotFoundError < MarathonError; end

  # Raised when a request returns a 409.
  class ConflictError < MarathonError; end

  # Raised when a request returns a 500.
  class ServerError < MarathonError; end

  # Raised when there is an unexpected response code / body.
  class UnexpectedResponseError < MarathonError; end

  # Raised when a request times out.
  class TimeoutError < MarathonError; end

  # Raised when login fails.
  class AuthenticationError < MarathonError; end

  # Raised when an IO action fails.
  class IOError < MarathonError; end

  def from_response(response)
    error_class(response).new(error_message(response))
  end

  private

  def error_class(response)
    case response.code
    when 400
      ClientError
    when 401
      UnauthorizedError
    when 404
      NotFoundError
    when 409
      ConflictError
    when 500
      ServerError
    else
      UnexpectedResponseError
    end
  end

  def error_message(response)
    json = JSON.parse(response.body)
    json['message'] || response.body
  end

  module_function :error_class, :error_message, :from_response

end