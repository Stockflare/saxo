module Saxo
  module User
    class Login < Saxo::Base
      values do
        attribute :user_id, String
        attribute :user_token, String
        attribute :identity, String
      end

      def call
        token = user_token
        raw_accounts = Saxo::User::Accounts.new(token: token).call.response.payload.accounts
        accounts = raw_accounts.map do |a|
          Saxo::Base::Account.new(
            account_number: a['AccountId'],
            name: a['AccountId']
          ).to_h
        end

        if '200' == '200'
          self.response = Saxo::Base::Response.new(raw: accounts,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        token: token,
                                                        accounts: accounts
                                                      },
                                                      messages: [])
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: result['code'],
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
