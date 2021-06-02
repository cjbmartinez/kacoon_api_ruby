module KacoonApiRuby
  class ErrorParser
    class << self
      def raise_errors_from(code:, error_message: nil)
        raise_error_for(code, error_message)

        # Default to Unexpected Error
        raise KacoonApiRuby::UnexpectedError
      end

      def raise_request_error(message)
        raise KacoonApiRuby::RequestError, message
      end

      private

      def raise_error_for(code, error_message)
        raise KacoonApiRuby::InvalidParameterError, error_message if code.in?(3000..3261)
        raise KacoonApiRuby::AuthenticationError, error_message if code == 4000
        raise KacoonApiRuby::InvalidTransactionError, error_message if code.in?(4001..7002)
      end
    end
  end
end
