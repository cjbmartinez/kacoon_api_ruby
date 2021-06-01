require "kacoon_api_ruby/json_parser"
require "kacoon_api_ruby/error_parser"
require 'http'

module KacoonApiRuby
  # Mr Speedy Abstract Class
  # @since 0.1.0
  class Base
    PRODUCTION_BASE_URL = nil.freeze
    # TODO: Update Production Base URL
    STAGING_BASE_URL = "https://staging.api.kacoon.co.uk".freeze
    HTTP_CONNECT_TIMEOUT = 22
    HTTP_WRITE_TIMEOUT = 22
    HTTP_READ_TIMEOUT = 22

    # @attr_reader [String] api_key - API Key
    # @attr_reader [String] api_secret - API Secret
    # @attr_reader [Boolean] sandbox - API call either to staging or production
    attr_reader :api_key, :api_secret, :sandbox

    def initialize(api_key:, api_secret:, sandbox: false)
      @api_key = api_key
      @api_secret = api_secret
      @sandbox = sandbox
    end

    def get(path:, payload: {})
      auth_token = authenticate[:token]
      response = http_call(method: :get, path: path, token: auth_token, params: payload)
      parsed_response = response.parsed_response

      validate_errors(parsed_response) unless response.success?

      parsed_response
    end

    def post(path:, payload: {})
      auth_token = authenticate.parsed_response[:token]
      response = http_call(method: :post, path: path, token: auth_token, json: payload)
      parsed_response = response.parsed_response

      validate_errors(parsed_response) unless response.success?

      parsed_response
    end

    private

    def authenticate
      authentication_body = { key: api_key, secret: api_secret }
      http_call(method: 'post', path: '/clients/auth', json: authentication_body)
    end

    def http_call(method:, path:, token: nil, json: {}, params: {})
      response = http.headers(default_headers(token: token))
                     .method(method)
                     .call(build_url(path), json: json, params: params)

      JSONParser.new(response)
    rescue HTTP::Error => e
      raise RequestError, e.message
    end

    def default_headers(token: nil)
      return { 'Content-Type': 'application/json' } unless token

      {
        'Content-Type': 'application/json',
        'Authorization': "Bearer: #{token}"
      }
    end

    def http
      @http ||= begin
        HTTP.timeout(connect: HTTP_CONNECT_TIMEOUT, write: HTTP_WRITE_TIMEOUT, read: HTTP_READ_TIMEOUT)
      end
    end

    def validate_errors(response)
      return unless response[:errors].present?

      ErrorParser.raise_errors_from(code: response[:errors].first[:code], error_message: response[:message])
    end

    def build_url(path)
      base_url = sandbox ? STAGING_BASE_URL : PRODUCTION_BASE_URL
      base_url + path
    end
  end
end
