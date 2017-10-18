module Saxo
  module Instrument
    class Details < Saxo::Base
      values do
        attribute :token, String
        attribute :ticker, String
      end

      def call
        tokens = Saxo.decode_token(token)
        raw_accounts = Saxo::User::Accounts.new(token: token).call.response
        raw_account = raw_accounts.raw['Data'][0]

        instrument_uri =  URI.join(Saxo.api_uri, "sim/openapi/ref/v1/instruments/?IncludeNonTradable=false&AssetTypes=Stock&Keywords=#{ticker}")

        instrument_req = Net::HTTP::Get.new(instrument_uri, initheader = {
                                    'Content-Type' => 'application/json',
                                    'Accept' => 'application/json',
                                    'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                  })

        instrument_resp = Saxo.call_api(instrument_uri, instrument_req)

        instrument_result = JSON.parse(instrument_resp.body)

        if instrument_resp.code == '200'
          uic_codes = instrument_result['Data'].map do |instrument|
            instrument['Identifier']
          end
          if uic_codes.length > 0

            price_uri =  URI.join(Saxo.api_uri, "sim/openapi/trade/v1/infoprices/list/?Amount=100&AccountKey=#{raw_account['AccountKey']}&AssetType=Stock&FieldGroups=DisplayAndFormat,InstrumentPriceDetails,PriceInfo,PriceInfoDetails,Quote&Uics=#{uic_codes.join(',')}")

            price_req = Net::HTTP::Get.new(price_uri, initheader = {
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json',
                                        'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                      })

            price_resp = Saxo.call_api(price_uri, price_req)

            price_result = JSON.parse(price_resp.body)

            if price_resp.code == '200'
              price_records =  price_result['Data'].select do |p|
                p['DisplayAndFormat']['Currency'] == 'USD' && p['DisplayAndFormat']['Symbol'].split(':')[0].downcase == ticker
              end
              if price_records.length > 0
                price_record = price_records[0]
                last_price = price_record['Quote']['Bid'] ? price_record['Quote']['Bid'].to_f : 0
                bid_price = price_record['Quote']['Bid'] ? price_record['Quote']['Bid'].to_f : 0
                ask_price = price_record['Quote']['Ask'] ? price_record['Quote']['Ask'].to_f : 0
                payload = {
                  type: 'success',
                  broker_id: price_record['Uic'],
                  ticker: ticker.downcase,
                  last_price: last_price,
                  bid_price: bid_price,
                  ask_price: ask_price,
                  order_size_max: 10000.0,
                  order_size_min: 1.0,
                  order_size_step: 1.0,
                  allow_fractional_shares: false,
                  timestamp: Time.now.utc.to_i,
                  warnings: [],
                  must_acknowledge: [],
                  token: token
                }

                self.response = Saxo::Base::Response.new(
                  raw: price_result,
                  payload: payload,
                  messages: [],
                  status: 200
                )
                Saxo.logger.info response.to_h
                self
              else
                raise Trading::Errors::OrderException.new(
                  type: :error,
                  code: result['code'],
                  description: 'ticker not found',
                  messages: 'ticker not found'
                )
              end
            else
              raise Trading::Errors::OrderException.new(
                type: :error,
                code: result['code'],
                description: 'ticker not found',
                messages: 'ticker not found'
              )
            end

          else
            raise Trading::Errors::OrderException.new(
              type: :error,
              code: result['code'],
              description: 'ticker not found',
              messages: 'ticker not found'
            )
          end
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: 'Login failed',
            messages: ['Login failed']
          )
        end
      end

      def parse_time(time_string)
        Time.parse(time_string).utc.to_i
      rescue
        Time.now.utc.to_i
      end
    end
  end
end
