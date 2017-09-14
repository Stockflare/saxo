module Saxo
  module User
    class Logout < Saxo::Base
      values do
        attribute :token, String
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/user/closeSession').to_s

        body = {
          token: token,
          apiKey: Saxo.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        self.response = Saxo::User.parse_result(result)

        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
