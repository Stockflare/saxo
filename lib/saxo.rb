require 'saxo/version'

require 'multi_json'
require 'yajl/json_gem'
require 'virtus'
require 'httparty'
require 'trading'

module Saxo
  autoload :Base, 'saxo/base'
  autoload :User, 'saxo/user'
  autoload :Positions, 'saxo/positions'
  autoload :Order, 'saxo/order'
  autoload :Instrument, 'saxo/instrument'

  class << self
    attr_writer :logger, :api_uri, :api_key, :price_service_url

    # Helper to configure .
    #
    # @yield [Odin] Yields the {Tradeit} module.
    def configure
      yield self
    end

    # Tradeit order statuses
    def order_statuses
      {
        'PENDING' => :pending,
        'OPEN' => :open,
        'FILLED' => :filled,
        'PART_FILLED' => :filling,
        'CANCELED' => :cancelled,
        'REJECTED' => :rejected,
        'NOT_FOUND' => :not_found,
        'PENDING_CANCEL' => :pending_cancel,
        'EXPIRED' => :expired
      }
    end

    # Tradeit brokers as symbols
    def brokers
      {
        td: 'TD',
        etrade: 'Etrade',
        scottrade: 'Scottrade',
        fidelity: 'Fidelity',
        schwab: 'Schwab',
        trade_station: 'TradeStation',
        robinhood: 'Robinhood',
        options_house: 'OptionsHouse',
        tradier: 'Tradier',
        trade_king: 'TradeKing',
        vanguard: 'Vanguard',
        ib: 'IB',
        dummy: 'Dummy'
      }
    end

    # Tradeit order actions
    def order_actions
      {
        buy: 'buy',
        sell: 'sell',
        buy_to_cover: 'buyToCover',
        sell_short: 'sellShort'
      }
    end

    def preview_order_actions
      {
        buy: 'buy',
        sell: 'sell',
        buy_to_cover: 'Buy to Cover',
        sell_short: 'Sell Short'
      }
    end

    def order_status_actions
      {
        'BUY' => :buy,
        'BUY_OPEN' => :buy_open,
        'BUY_CLOSE' => :buy_close,
        'BUY_TO_COVER' => :buy_to_cover,
        'SELL' => :sell,
        'SELL_OPEN' => :sell_open,
        'SELL_CLOSE' => :sell_close,
        'SELL_SHORT' => :sell_short,
        'UNKNOWN' => :unknown
      }
    end

    def place_order_actions
      {
        buy: 'buy',
        sell: 'sell',
        buy_to_cover: 'buyToCover',
        sell_short: 'sellShort'
      }
    end

    # Tradeit price types
    def price_types
      {
        market: 'market',
        limit: 'limit',
        stop_market: 'stopMarket',
        stop_limit: 'stopLimit'
      }
    end

    # Tradeit order expirations
    def order_expirations
      {
        day: 'day',
        gtc: 'gtc'
      }
    end

    def order_status_expirations
      {
        'DAY' => :day,
        'GTC' => :gtc,
        'GOOD_TROUGH_DATE' => :gtd,
        'UNKNOWN' => :unknown
      }
    end

    def preview_order_expirations
      {
        day: 'day',
        gtc: 'gtc'
      }
    end

    def api_uri
      if @api_uri
        return @api_uri
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'api_uri missing',
          messages: ['api_uri configuration variable has not been set']
        )
      end
    end

    def api_key
      if @api_key
        return @api_key
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'api_key missing',
          messages: ['api_key configuration variable has not been set']
        )
      end
    end

    def price_service_url
      if @price_service_url
        return @price_service_url
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'price_service_url missing',
          messages: ['price_service_url configuration variable has not been set']
        )
      end
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
end
