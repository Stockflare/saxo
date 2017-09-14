module Saxo
  module User
    class OauthUrlMobile < Saxo::Base
      values do
        attribute :broker, Symbol
        attribute :callback_url, String
      end

      def call
        uri =  URI.join(Saxo.api_uri, 'v1/user/getOAuthLoginPopupUrlForMobile').to_s
        body = {
          broker: Saxo.brokers[broker],
          apiKey: Saxo.app_key,
          interAppAddressCallback: callback_url
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        url: result['oAuthURL']
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
