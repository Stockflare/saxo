require 'saxo/version'

require 'multi_json'
require 'yajl/json_gem'
require 'virtus'
require 'httparty'
require 'trading'
require "base64"


require 'pry-byebug'

module Saxo
  autoload :Base, 'saxo/base'
  autoload :User, 'saxo/user'
  autoload :Positions, 'saxo/positions'
  autoload :Order, 'saxo/order'
  autoload :Instrument, 'saxo/instrument'

  class << self
    attr_writer :logger, :api_uri, :app_key, :app_url, :authentication_url, :app_secret

    # Helper to configure .
    #
    # @yield [Odin] Yields the {Tradeit} module.
    def configure
      yield self
    end

    # Tradeit order statuses
    def order_statuses
      {
        'LockedPlacementPending' => :pending,
        'Working' => :open,
        'Filled' => :filled,
        'PART_FILLED' => :filling,
        'NotWorking' => :cancelled,
        'REJECTED' => :rejected,
        'NOT_FOUND' => :not_found,
        'WorkingLockedCancelPending' => :pending_cancel,
        'EXPIRED' => :expired
      }
    end

    # Tradeit brokers as symbols
    def brokers
      {
        saxo: 'Saxo'
      }
    end

    # Tradeit order actions
    def order_actions
      {
        buy: 'Buy',
        sell: 'Sell',
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
        'Buy' => :buy,
        'BUY_OPEN' => :buy_open,
        'BUY_CLOSE' => :buy_close,
        'BUY_TO_COVER' => :buy_to_cover,
        'Sell' => :sell,
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
        'DayOrder' => :day,
        'GoodTillCancel' => :gtc,
        'GoodTillDate' => :gtd,
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

    def app_key
      if @app_key
        return @app_key
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'app_key missing',
          messages: ['app_key configuration variable has not been set']
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

    def app_url
      if @app_url
        return @app_url
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'app_url missing',
          messages: ['app_url configuration variable has not been set']
        )
      end
    end

    def authentication_url
      if @authentication_url
        return @authentication_url
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'authentication_url missing',
          messages: ['authentication_url configuration variable has not been set']
        )
      end
    end

    def app_secret
      if @app_secret
        return @app_secret
      else
        raise Trading::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'app_secret missing',
          messages: ['app_secret configuration variable has not been set']
        )
      end
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
    def call_api(uri, req)
      Net::HTTP.start(uri.hostname, uri.port,
                      use_ssl: uri.scheme == 'https') do |http|
        http.set_debug_output($stdout)
        http.request(req)
      end
    end

    def decode_token(token)
      JSON.parse(Base64.urlsafe_decode64(token))
    end
  end
end
