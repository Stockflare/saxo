module Saxo
  module Positions
    class Get < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :page, Integer, default: 0
      end

      def call
        tokens = Saxo.decode_token(token)

        uri =  URI.join(Saxo.api_uri, 'sim/openapi/port/v1/positions/me?FieldGroups=PositionView,PositionBase,DisplayAndFormat')

        req = Net::HTTP::Get.new(uri, initheader = {
                                    'Content-Type' => 'application/json',
                                    'Accept' => 'application/json',
                                    'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                  })

        resp = Saxo.call_api(uri, req)

        result = JSON.parse(resp.body)
        binding.pry
        if resp.code == '200'
          positions = result['Data'].map do |p|
            if p['PositionBase']['AccountId'] == account_number
              Saxo::Base::Position.new(
                quantity: p['PositionBase']['Amount'],
                cost_basis: p['costbasis'],
                ticker: p['symbol'].downcase,
                instrument_class: p['symbolClass'].downcase,
                change: p['totalGainLossDollar'],
                holding: p['holdingType'].downcase
              ).to_h
            else
              nil
            end
          end.compact
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        client_id: result['ClientId'],
                                                        client_key: result['ClientKey'],
                                                        token: token,
                                                      },
                                                      messages: [])
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
