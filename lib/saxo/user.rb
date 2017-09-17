# User based actions fro the Tradeit API
#
#
module Saxo
  module User
    autoload :Link, 'saxo/user/link'
    autoload :Login, 'saxo/user/login'
    autoload :LinkAndLogin, 'saxo/user/link_and_login'
    autoload :Verify, 'saxo/user/verify'
    autoload :Logout, 'saxo/user/logout'
    autoload :Refresh, 'saxo/user/refresh'
    autoload :Account, 'saxo/user/account'
    autoload :OauthLink, 'saxo/user/oauth_link'
    autoload :OauthUrl, 'saxo/user/oauth_url'
    autoload :OauthUrlMobile, 'saxo/user/oauth_url_mobile'
    autoload :Client, 'saxo/user/client'
    autoload :Accounts, 'saxo/user/accounts'

    class << self
      #
      # Parse a Tradeit Login or Verify response into our format
      #
      def parse_result(result)
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          accounts = []
          if result['accounts']
            accounts = result['accounts'].map do |a|
              Saxo::Base::Account.new(
                account_number: a['accountNumber'],
                name: a['name']
              ).to_h
            end
          end
          response = Saxo::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   type: 'success',
                                                   token: result['token'],
                                                   accounts: accounts
                                                 },
                                                 messages: [result['shortMessage']].compact)
        elsif result['status'] == 'INFORMATION_NEEDED'
          #
          # User Asked for security question
          #
          if result['challengeImage']
            data = {
              encoded: result['challengeImage']
            }
          else
            data = {
              question: result['securityQuestion'],
              answers: result['securityQuestionOptions']
            }
          end
          response = Saxo::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   type: 'verify',
                                                   challenge: result['challengeImage'] ? 'image' : 'question',
                                                   token: result['token'],
                                                   data: data
                                                 },
                                                 messages: [result['shortMessage']].compact)
        else
          #
          # Login failed
          #
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end

        # pp(response.to_h)
        response
      end
    end
  end
end
