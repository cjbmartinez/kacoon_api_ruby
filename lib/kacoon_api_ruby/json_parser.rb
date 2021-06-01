require "json"

module KacoonApiRuby
  class JSONParser
    def initialize(raw_response)
      @raw_response = raw_response
    end

    delegate :status, :code, to: :raw_response
    delegate :success?, to: :status

    def parsed_response
      raw_response.parse.deep_symbolize_keys
    rescue JSON::ParserError
      {}
    end

    private

    attr_reader :raw_response
  end
end
