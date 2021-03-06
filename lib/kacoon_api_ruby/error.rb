module KacoonApiRuby
  class KacoonApiError < StandardError; end
  class RequestError < KacoonApiError; end
  class UnexpectedError < KacoonApiError; end
  class InvalidParameterError < KacoonApiError; end
  class AuthenticationError < KacoonApiError; end
  class InvalidTransactionError < KacoonApiError; end
end
