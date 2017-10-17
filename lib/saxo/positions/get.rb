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
        if resp.code == '200'
          positions = result['Data'].map do |p|
            if p['PositionBase']['AccountId'] == account_number
              cost_basis = p['PositionBase']['OpenPrice'] ? p['PositionBase']['OpenPrice'].to_f * p['PositionBase']['Amount'].to_f : 0.0
              symbol = p['DisplayAndFormat']['Symbol'].split(':')[0]
              change = 0.0
              if p['PositionView'] && p['PositionView']['ProfitLossOnTradeInBaseCurrency']
                change = p['PositionView']['ProfitLossOnTradeInBaseCurrency'].to_f
              end
              Saxo::Base::Position.new(
                quantity: p['PositionBase']['Amount'],
                cost_basis: cost_basis.round(2),
                ticker: symbol.downcase,
                instrument_class: 'EQUITY_OR_ETF'.downcase,
                change: change,
                holding: 'long'
              ).to_h
            else
              nil
            end
          end.compact
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        positions: positions,
                                                        pages: 1,
                                                        page: 0,
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
    end
  end
end
