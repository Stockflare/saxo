module Saxo
  module User
    class Login < Saxo::Base
      values do
        attribute :user_id, String
        attribute :user_token, String
        attribute :identity, String
      end

      def call
        path = "v1/user/authenticate"
        if identity
          path = "v1/user/authenticate?srv=#{identity}"
        end
        uri =  URI.join(Saxo.api_uri, path).to_s

        body = {
          userId: user_id,
          userToken: user_token,
          apiKey: Saxo.app_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)

        self.response = Saxo::User.parse_result(result)

        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
