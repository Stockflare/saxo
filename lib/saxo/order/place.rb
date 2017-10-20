require 'digest'

module Saxo
  module Order
    class Place < Saxo::Base
      values do
        attribute :token, String
        attribute :price, Float
      end

      def call
        # Get the Order Details from the cache

        begin
          tokens = Saxo.decode_token(token)
          preview = JSON.parse(Saxo.cache.get("#{Saxo::CACHE_PREFIX}_#{Digest::SHA256.base64digest(tokens['access_token'])}"))
          if preview
            body = {
              AccountKey: preview['raw']['account']['AccountKey'],
              OrderType: Saxo.price_types[preview['raw']['price_type'].to_sym],
              AssetType: 'Stock',
              OrderRelation: 'StandAlone',
              BuySell: Saxo.order_actions[preview['raw']['order_action'].to_sym],
              OrderDuration: {
                DurationType: Saxo.order_expirations[preview['raw']['expiration'].to_sym]
              },
              Uic: preview['raw']['instrument']['broker_id']
            }

            # Priortise Amount orders over quantity
            # if preview['raw'].has_key?('amount') && preview['raw']['amount'].to_f > 0
            #   body[:orderQty] = 0.0
            #   body[:amountCash] = preview['raw']['amount'].to_f
            # else
            #   body[:orderQty] = preview['raw']['quantity'].to_f
            # end

            body[:Amount] = preview['raw']['quantity'].to_f

            body[:StopLimitPrice] = price if preview['raw']['price_type'].to_sym == :stop_limit
            body[:OrderPrice] = price if preview['raw']['price_type'].to_sym == :stop_market
            body[:OrderPrice] = price if preview['raw']['price_type'].to_sym == :limit

            uri =  URI.join(Saxo.api_uri, "sim/openapi/trade/v1/orders")

            req = Net::HTTP::Post.new(uri, initheader = {
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json',
                                        'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                      })

            req.body = body.to_json
            resp = Saxo.call_api(uri, req)

            result = JSON.parse(resp.body)
            if resp.code == '201'
              order_id = result['MasterOrder']['OrderId']

              case preview['raw']['price_type'].to_sym
              when :market
                price_label = 'Market'
              when :limit
                price_label = 'Limit'
              when :stop_market
                price_label = 'Stop on Quote'
              else
                price_label = 'Unknown'
              end

              payload = {
                type: 'success',
                ticker: preview['raw']['ticker'],
                order_action: preview['raw']['order_action'].to_sym,
                quantity: preview['raw']['quantity'].to_f,
                expiration: preview['raw']['expiration'].to_sym,
                price_label: price_label,
                message: 'success',
                last_price: preview['raw']['instrument']['lastTrade'].to_f,
                bid_price: preview['raw']['instrument']['rateBid'].to_f,
                ask_price: preview['raw']['instrument']['rateAsk'].to_f,
                price_timestamp: Time.now.utc.to_i,
                timestamp: Time.now.utc.to_i,
                order_number: order_id,
                token: token,
                price: price
              }

              self.response = Saxo::Base::Response.new(
                raw: result,
                payload: payload,
                messages: ['success'],
                status: 200
              )
            else
              raise Trading::Errors::OrderException.new(
                type: :error,
                code: resp.code,
                description: result['message'],
                messages: result['message']
              )
            end
          else
            raise Trading::Errors::OrderException.new(
              type: :error,
              code: '403',
              description: 'Order could not be found',
              messages: 'Order could not be found'
            )
          end
        rescue Exception => e
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
