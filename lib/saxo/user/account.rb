module Saxo
  module User
    class Account < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/balance/getAccountOverview').to_s

        body = {
          token: token,
          accountNumber: account_number,
          apiKey: Saxo.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'
          payload = {
            type: 'success',
            cash: result['availableCash'].to_f,
            power: result['buyingPower'].to_f,
            day_return: result['dayAbsoluteReturn'].to_f,
            day_return_percent: result['dayPercentReturn'].to_f / 100.0 ,
            total_return: result['totalAbsoluteReturn'].to_f,
            total_return_percent: result['totalPercentReturn'].to_f / 100.0,
            base_currency_code: result['accountBaseCurrency'].downcase,
            value: result['totalValue'].to_f,
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
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        Saxo.logger.info response.to_h
        # pp(self.response.to_h)
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
