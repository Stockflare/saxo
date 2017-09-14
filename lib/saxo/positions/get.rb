module Saxo
  module Positions
    class Get < Saxo::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :page, Integer, default: 0
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/position/getPositions').to_s

        body = {
          token: token,
          accountNumber: account_number,
          page: page,
          apiKey: Saxo.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        self.response = Saxo::Positions.parse_result(result)

        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
