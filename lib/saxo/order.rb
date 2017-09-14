# User based actions fro the Tradeit API
#
#
module Saxo
  module Order
    autoload :Preview, 'saxo/order/preview'
    autoload :Place, 'saxo/order/place'
    autoload :Status, 'saxo/order/status'
    autoload :Cancel, 'saxo/order/cancel'

    class << self
      def parse_order_details(details)
        orders = []
        details.each do |detail|
          detail['orderLegs'].each do |leg|
            filled_value = leg['fills'].inject(0) { |sum, f| sum + (f['quantity'].to_i * f['price'].to_f) }
            filled_quantity = leg['fills'].inject(0) { |sum, f| sum + f['quantity'].to_i }
            filled_price = filled_quantity != 0 ? filled_value / filled_quantity : 0.0
            order = {
              ticker: leg['symbol'].downcase,
              order_action: Saxo.order_status_actions[leg['action']],
              filled_quantity: filled_quantity.to_f,
              filled_price: filled_price,
              filled_total: filled_value.to_f,
              order_number: detail['orderNumber'],
              quantity: leg['orderedQuantity'].to_i,
              expiration: Saxo.order_status_expirations[detail['orderExpiration']],
              status: Saxo.order_statuses[detail['orderStatus']]
            }
            orders.push order
          end
        end
        orders
      end
    end
  end
end
