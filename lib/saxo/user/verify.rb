module Saxo
  module User
    class Verify < Saxo::Base
      values do
        attribute :token, String
        attribute :answer, String
        attribute :identity, String
      end

      def call
        path = "v1/user/answerSecurityQuestion"
        if identity
          path = "v1/user/answerSecurityQuestion?srv=#{identity}"
        end
        uri =  URI.join(Saxo.api_uri, path).to_s

        body = {
          securityAnswer: answer,
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
