module Saxo
  module User
    class Link < Saxo::Base
      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/user/oAuthLink').to_s
        body = {
          id: username,
          password: password,
          broker: Saxo.brokers[broker],
          apiKey: Saxo.app_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        user_id: result['userId'],
                                                        user_token: result['userToken']
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
