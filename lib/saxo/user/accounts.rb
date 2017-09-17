module Saxo
  module User
    class Accounts < Saxo::Base
      values do
        attribute :token, String
      end

      def call
        tokens = Saxo.decode_token(token)

        uri =  URI.join(Saxo.api_uri, '/sim/openapi/port/v1/accounts/me')

        req = Net::HTTP::Get.new(uri, initheader = {
                                    'Content-Type' => 'application/json',
                                    'Accept' => 'application/json',
                                    'Authorization' => "#{tokens['token_type']} #{tokens['access_token']}"
                                  })

        resp = Saxo.call_api(uri, req)

        result = JSON.parse(resp.body)

        if resp.code == '200'
          self.response = Saxo::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        accounts: result['Data'],
                                                        token: token,
                                                      },
                                                      messages: [])
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: resp.code,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end

        Saxo.logger.info response.to_h
        self
      end
    end
  end
end
