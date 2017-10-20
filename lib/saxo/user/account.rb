module Saxo
  module User
    class Account < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
      end

      def call

        tokens = Saxo.decode_token(token)
        raw_accounts = Saxo::User::Accounts.new(token: token).call.response.payload.accounts
        account = raw_accounts.select{|a| a['AccountId'] === account_number}[0]

        if account
          uri =  URI.join(Saxo.api_uri, "sim/openapi/port/v1/balances/?ClientKey=#{account['ClientKey']}&AccountGroupKey=#{account['AccountGroupKey']}&AccountKey=#{account['AccountKey']}")

          req = Net::HTTP::Get.new(uri, initheader = {
                                      'Content-Type' => 'application/json',
                                      'Accept' => 'application/json',
                                      'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                    })

          resp = Saxo.call_api(uri, req)

          result = JSON.parse(resp.body)

          if resp.code == '200'
            payload = {
              type: 'success',
              cash: result['CashBalance'].to_f,
              power: result['CashBalance'].to_f,
              day_return: 0.0,
              day_return_percent: 0.0 ,
              total_return: 0.0,
              total_return_percent: 0.0,
              base_currency_code: result['Currency'].downcase,
              value: result['UnrealizedPositionsValue'].to_f,
              token: token
            }

            # Deal with positions to create summary values
            raw_positions = Saxo::Positions::Get.new(token: token, account_number: account_number).call.response.raw
            total_cost_basis = 0.0
            total_return = 0.0
            total_day_return = 0.0
            total_market_value = 0.0
            total_close_market_value = 0.0
            if raw_positions['Data'] && raw_positions['Data'].length > 0
              raw_positions['Data'].each do |p|
                if p['PositionBase']['AccountId'] == account_number
                  total_cost_basis += p['PositionBase']['OpenPrice'].to_f * p['PositionBase']['Amount'].to_f
                  if p['PositionView']
                    total_return += p['PositionView']['ProfitLossOnTradeInBaseCurrency'].to_f
                    total_day_return += ((p['PositionBase']['OpenPrice'].to_f * p['PositionBase']['Amount'].to_f) * p['PositionView']['InstrumentPriceDayPercentChange'].to_f)
                    total_market_value += (p['PositionView']['CurrentPrice'].to_f * p['PositionBase']['Amount'].to_f)
                  end
                end
              end
            else
            end

            payload[:day_return] = total_day_return.round(4)
            payload[:total_return] = total_return.round(4)
            if total_cost_basis > 0
              payload[:total_return_percent] = (total_return / total_cost_basis).round(4)
            end
            if (total_market_value - total_day_return) != 0
              payload[:day_return_percent] = (total_day_return / (total_market_value - total_day_return)).round(4)
            end
            self.response = Saxo::Base::Response.new(
              raw: result.merge('AccountKey' => account['AccountKey']),
              payload: payload,
              messages: [],
              status: 200
            )
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
