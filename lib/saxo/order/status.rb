module Saxo
  module Order
    class Status < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call

        tokens = Saxo.decode_token(token)

        uri =  URI.join(Saxo.api_uri, 'sim/openapi/port/v1/orders/me?FieldGroups=DisplayAndFormat,ExchangeInfo&Status=All')

        req = Net::HTTP::Get.new(uri, initheader = {
                                    'Content-Type' => 'application/json',
                                    'Accept' => 'application/json',
                                    'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                  })

        resp = Saxo.call_api(uri, req)

        result = JSON.parse(resp.body)
        if resp.code == '200'
          orders = result['Data'].map do |order|
            if order['AccountId'] == account_number
              ticker = order['DisplayAndFormat']['Symbol'].split(':')[0]
              filled_quantity = 0
              if order['FilledAmount']
                filled_quantity = order['FilledAmount'].to_f
              end
              filled_price = 0.0
              if order['MarketPrice']
                filled_price = order['MarketPrice'].to_f
              end

              {
                ticker: ticker.downcase,
                order_action: Saxo.order_status_actions[order['BuySell']],
                filled_quantity: filled_quantity,
                filled_price: filled_price,
                filled_total: filled_price * filled_quantity,
                order_number: order['OrderId'],
                quantity: order['Amount'].to_f,
                expiration: Saxo.order_status_expirations[order['Duration']['DurationType']],
                status: Saxo.order_statuses[order['Status']]
              }
            else
              nil
            end
          end.compact

          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        orders: orders,
                                                        token: token
                                                      },
                                                      messages: [])
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: 'Login failed',
            messages: ['Login failed']
          )
        end
        Saxo.logger.info response.to_h
        self
      end

      def parse_time(time_string)
        Time.parse(time_string).utc.to_i
      rescue
        Time.now.utc.to_i
      end
    end
  end
end
