module Saxo
  module Order
    class Preview < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_action, Symbol
        attribute :quantity, Integer
        attribute :ticker, String
        attribute :price_type, Symbol
        attribute :expiration, Symbol
        attribute :limit_price, Float
        attribute :stop_price, Float
        attribute :amount, Float
      end

      def call
        # Tradeit does not support order amounts
        if amount && amount != 0.0
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: 500,
            description: 'Amount is not supported',
            messages: 'Amount is not supported'
          )
        end

        uri =  URI.join(Saxo.api_uri, 'v1/order/previewStockOrEtfOrder').to_s

        body = {
          token: token,
          accountNumber: account_number,
          orderAction: Saxo.order_actions[order_action],
          orderQuantity: quantity,
          orderSymbol: ticker,
          orderPriceType: Saxo.price_types[price_type],
          orderExpiration: Saxo.order_expirations[expiration],
          apiKey: Saxo.app_key
        }

        body[:orderLimitPrice] = limit_price if price_type == :limit || price_type == :stop_limit
        body[:orderStopPrice] = stop_price if price_type == :stop_market || price_type == :stop_limit

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'REVIEW_ORDER'
          details = result['orderDetails']
          # binding.pry
          payload = {
            type: 'review',
            ticker: details['orderSymbol'].downcase,
            order_action: Saxo.preview_order_actions.key(details['orderAction']),
            quantity: details['orderQuantity'].to_i,
            expiration: Saxo.preview_order_expirations.key(details['orderExpiration']),
            price_label: details['orderPrice'],
            value_label: details['orderValueLabel'],
            message: details['orderMessage'],
            last_price: details['lastPrice'].to_f,
            bid_price: details['bidPrice'].to_f,
            ask_price: details['askPrice'].to_f,
            timestamp: parse_time(details['timestamp']),
            buying_power: details['buyingPower'].to_f,
            estimated_commission: details['estimatedOrderCommission'].to_f,
            estimated_value: details['estimatedOrderValue'].to_f,
            estimated_total: details['estimatedTotalValue'].to_f,
            warnings: result['warningsList'].compact,
            must_acknowledge: result['ackWarningsList'].compact,
            amount: amount,
            token: result['token']
          }

          self.response = Saxo::Base::Response.new(
            raw: result,
            payload: payload,
            messages: result['shortMessage'].to_a.compact,
            status: 200
          )
        else
          #
          # Order failed
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
