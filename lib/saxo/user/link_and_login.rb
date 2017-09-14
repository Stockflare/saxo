module Saxo
  module User
    class LinkAndLogin < Saxo::Base
      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        link = Saxo::User::Link.new(
          broker: broker,
          username: username,
          password: password
        ).call.response

        self.response = Saxo::User::Login.new(
          user_id: link.payload[:user_id],
          user_token: link.payload[:user_token]
        ).call.response

        self
      end
    end
  end
end
