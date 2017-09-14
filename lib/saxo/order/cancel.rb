module Saxo
  module Order
    class Cancel < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/order/cancelOrder').to_s

        body = {
          token: token,
          accountNumber: account_number,
          orderNumber: order_number,
          apiKey: Saxo.app_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'

          payload = {
            type: 'success',
            orders: Saxo::Order.parse_order_details(result['orderStatusDetailsList']),
            token: result['token']
          }

          self.response = Saxo::Base::Response.new(
            raw: result,
            payload: payload,
            messages: Array(result['shortMessage']),
            status: 200
          )
        else
          #
          # Status failed
          #
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
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
