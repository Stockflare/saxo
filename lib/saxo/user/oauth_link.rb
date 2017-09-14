module Saxo
  module User
    class OauthLink < Saxo::Base
      values do
        attribute :o_auth_verifier, String
        attribute :broker, Symbol
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/user/getOAuthAccessToken').to_s
        body = {
          oAuthVerifier: o_auth_verifier,
          apiKey: Saxo.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        user_id: result['userId'],
                                                        user_token: result['userToken'],
                                                        activation_time: result['activationTime']
                                                      },
                                                      messages: [result['shortMessage']].compact)
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        # pp response.to_h
        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
