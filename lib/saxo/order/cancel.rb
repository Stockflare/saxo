module Saxo
  module Order
    class Cancel < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call
        tokens = Saxo.decode_token(token)
        account_call = Saxo::User::Account.new(token: token, account_number: account_number).call.response
        raw_account = account_call.raw
        uri =  URI.join(Saxo.api_uri, "sim/openapi/trade/v1/orders/#{order_number}/?AccountKey=#{raw_account['AccountKey']}")

        req = Net::HTTP::Delete.new(uri, initheader = {
                                    'Content-Type' => 'application/json',
                                    'Accept' => 'application/json',
                                    'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                  })

        resp = Saxo.call_api(uri, req)

        result = JSON.parse(resp.body)
        if resp.code == '200'
          payload = {
            type: 'success',
            orders: [result['OrderId']],
            token: token
          }

          self.response = Saxo::Base::Response.new(
            raw: result,
            payload: payload,
            messages: Array('Order deleted'),
            status: 200
          )
        else
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: '403',
            description: 'Order could not be found',
            messages: 'Order could not be found'
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
