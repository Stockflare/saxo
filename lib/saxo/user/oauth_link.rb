module Saxo
  module User
    class OauthLink < Saxo::Base
      values do
        attribute :o_auth_verifier, String
        attribute :broker, Symbol
      end

      def call
        uri =  URI.join(Saxo.authentication_url, '/token')

        auth = "#{Saxo.app_key}:#{Saxo.app_secret}"
        auth_64 = Base64.urlsafe_encode64(auth)

        req = Net::HTTP::Post.new(uri, initheader = {
                                    'Content-Type' => 'application/x-www-form-urlencoded',
                                    'Accept' => 'application/json',
                                    'Authorization' => "Basic #{auth_64}"
                                  })
        # req.body = body.to_json
        req.body = "grant_type=authorization_code&code=#{o_auth_verifier}"

        resp = Saxo.call_api(uri, req)

        result = JSON.parse(resp.body)

        if resp.code == '201'
          token = Base64.urlsafe_encode64(result.to_json)
          user_id = Saxo::User::Client.new(token: token).call.response.payload.client_id
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        user_id: user_id,
                                                        user_token: token,
                                                        activation_time: ''
                                                      },
                                                      messages: [result['shortMessage']].compact)
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: resp.body,
            messages: [resp.body]
          )
        end
        # pp response.to_h
        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
