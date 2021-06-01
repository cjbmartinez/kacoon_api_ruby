require "kacoon_api_ruby/base"

module KacoonApiRuby
  class Client < Base
    def process_payment(payload:)
      post(path: '/clients/payments', payload: payload.deep_symbolize_keys)
    end
  end
end
