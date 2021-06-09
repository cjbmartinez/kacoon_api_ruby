require 'rails_helper'

RSpec.describe KacoonApiRuby::Client do
  describe 'process_payment' do
    let(:api_key) { 'test_key' }
    let(:api_secret) { 'test_secret' }

    let(:mock_http_with_header) { double('MockHttpWithHeader') }
    let(:mock_http) { double('MockHttp', headers: mock_http_with_header) }
    let(:mock_http_with_method) { double('MockHttpWithMethod') }
    let(:mock_http_result) { double('MockHttpResult') }
    let(:expected_uri) { 'https://staging.api.kacoon.co.uk' }
    let(:success) { true }
    let(:parsed_response) { {} }

    let(:mock_parsed_response) do
      instance_double(KacoonApiRuby::JSONParser, raw_response: mock_http_result, parsed_response: parsed_response, success?: success)
    end

    let(:mock_payment_payload) do
      {
        "client_transaction_id": "752006",
        "client_notifications_url": "https://www.acme.com/notifications",
        "client_redirect_url": "https://www.acme.com/redirect",
        "payment_amount": "2",
        "payment_amount_currency": "EUR",
        "payment_description": "Widget",
        "card_number": "yourcardnumber",
        "card_expire_month": "02",
        "card_expire_year": "2022",
        "card_cvv": "123",
        "device_ip_address": "112.207.113.167",
        "customer_family_name": "Bloggs",
        "customer_given_name": "Joe",
        "customer_email": "joe.bloggs@bloggsville.com",
        "customer_address_1": "1 Bloggs Street",
        "customer_address_2": "",
        "customer_city": "Bloggsville",
        "customer_postal_code": "SW1 2VW",
        "customer_country": "DE",
        "customer_phone": "+44 1122 3344 55",
        "strong_authentication": {
          "browser_accept_header": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,applica",
          "browser_user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 S",
          "browser_language": "en-GB",
          "browser_javascript_enabled": true,
          "browser_java_enabled": false,
          "browser_time_zone": -480,
          "browser_screen_width": 2560,
          "browser_screen_height": 1440,
          "browser_screen_color_depth": 30
        }
      }
    end
    let(:expected_auth_options) { { params: {}, json: { :key=>"test_key", :secret=>"test_secret" } } }
    let(:expected_payment_options) { { params: {}, json: mock_payment_payload } }

    before do
      expect(HTTP).to receive(:timeout).and_return(mock_http)
      expect(mock_http_with_header).to receive(:method).with(:post).and_return(mock_http_with_method).twice
    end

    subject { described_class.new(api_key: api_key, api_secret: api_secret, sandbox: true) }

    context 'when success' do
      it 'authenticates and execute process payment' do
        expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/auth', expected_auth_options)
                                                       .and_return(mock_http_result)
        expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/payments', expected_payment_options)
                                                       .and_return(mock_http_result)

        expect(KacoonApiRuby::JSONParser).to receive(:new).with(mock_http_result)
                                                          .and_return(mock_parsed_response).twice

        subject.process_payment(payload: mock_payment_payload)
      end
    end

    context 'when failure' do
      context 'when http request error raise' do
        [
          HTTP::ConnectionError,
          HTTP::RequestError,
          HTTP::ResponseError,
          HTTP::StateError,
          HTTP::TimeoutError,
          HTTP::HeaderError
        ].each do |http_error|
          context "when #{http_error}" do
            let(:http_error) { http_error }

            before do
              expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/auth', expected_auth_options)
                                                             .and_return(mock_http_result)
              expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/payments', expected_payment_options).and_raise(http_error)

              expect(KacoonApiRuby::JSONParser).to receive(:new).with(mock_http_result)
                                                          .and_return(mock_parsed_response)
            end

            it { expect { subject.process_payment(payload: mock_payment_payload) }.to raise_error(KacoonApiRuby::RequestError) }
          end
        end
      end

      context 'when invalid transaction' do
        let(:success) { false }
        let(:parsed_response) do
          {
            errors: [ { code: error_code } ],
            message: error_message
          }
        end

        before do
          expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/auth', expected_auth_options)
                                                          .and_return(mock_http_result)
          expect(mock_http_with_method).to receive(:call).with(expected_uri + '/clients/payments', expected_payment_options)
                                                          .and_return(mock_http_result)

          expect(KacoonApiRuby::JSONParser).to receive(:new).with(mock_http_result)
                                                      .and_return(mock_parsed_response).twice
        end

        context 'and error code within 3000 to 3261' do
          let(:error_code) { 3000 }
          let(:error_message) { 'Invalid Parameter' }

          it do
            expect { subject.process_payment(payload: mock_payment_payload) }.to raise_error(
              KacoonApiRuby::InvalidParameterError, 'Invalid Parameter'
            )
          end
        end

        context 'and error code is 4000' do
          let(:error_code) { 4000 }
          let(:error_message) { 'Auth Error' }

          it do
            expect { subject.process_payment(payload: mock_payment_payload) }.to raise_error(
              KacoonApiRuby::AuthenticationError, 'Auth Error'
            )
          end
        end

        context 'and error code is between 4001 to 7002' do
          let(:error_code) { 4001 }
          let(:error_message) { 'Invalid transaction' }

          it do
            expect { subject.process_payment(payload: mock_payment_payload) }.to raise_error(
              KacoonApiRuby::InvalidTransactionError, 'Invalid transaction'
            )
          end
        end
      end
    end
  end
end