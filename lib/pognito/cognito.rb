#frozen_string_literal: true

module Pognito
  class Cognito
    attr_reader :storage

    def self.client(storage:)
      @client ||= Aws::CognitoIdentityProvider::Client.new(
        region: ENV['AWS_COGNITO_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY'],
        secret_access_key: ENV['AWS_SECRET_KEY']
      )

      @storage ||= storage

      return self.new(storage: @storage, client: @client)
    end

    def initialize(storage:, client:)
      @storage = storage
      @client = client
    end

    def user
      begin
        user = @client.get_user({access_token: access_token}) if access_token
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        user = nil
      end

      unless user
        unset_tokens

        return nil
      end

      {
        username: user.username,
      }.merge(user.user_attributes.map { |attr| [attr.name, attr.value] }.to_h.symbolize_keys)
    end

    def set_tokens(code)
      tokens = tokens_from_code(code)

      @storage[:access_token] = tokens["access_token"]
      @storage[:refresh_token] = tokens["refresh_token"]
    end

    def sign_in_url
      url = "https://#{ENV['AWS_COGNITO_DOMAIN']}/oauth2/authorize"

      "#{url}?response_type=code" \
        "&client_id=#{ENV['AWS_COGNITO_APP_CLIENT_ID']}" \
        "&scope=#{scope("email", "openid", "phone", "aws.cognito.signin.user.admin")}" \
        "&redirect_uri=#{ENV['AWS_COGNITO_REDIRECT_URI']}/login"
    end

    def sign_out
      if tokens?
        begin
          @client.global_sign_out({access_token: access_token})
          unset_tokens
        rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
          # silence revoked token errors
        end
      end
    end

    def sign_out_url
      "https://#{ENV['AWS_COGNITO_DOMAIN']}/logout" \
        "?client_id=#{ENV['AWS_COGNITO_APP_CLIENT_ID']}" \
        "&logout_uri=#{ENV['AWS_COGNITO_REDIRECT_URI']}/"
    end

    def tokens?
      access_token && refresh_token
    end

    private
      def scope(*args)
        args.join('+')
      end

      def encoded_client_credentials
        Base64.strict_encode64("#{ENV['AWS_COGNITO_APP_CLIENT_ID']}:#{ENV['AWS_COGNITO_APP_CLIENT_SECRET']}")
      end

      def unset_tokens
        @current_user = nil

        @storage.delete(:access_token)
        @storage.delete(:refresh_token)
      end

      def access_token
        @storage[:access_token]
      end

      def refresh_token
        @storage[:refresh_token]
      end

      def tokens_from_code(code)
        headers = {
          Authorization: "Basic #{encoded_client_credentials}",
          "Content-Type": "application/x-www-form-urlencoded"
        }

        body = {
          grant_type: "authorization_code",
          client_id: ENV['AWS_COGNITO_APP_CLIENT_ID'],
          code: code,
          redirect_uri: "#{ENV['AWS_COGNITO_REDIRECT_URI']}/login"
        }

        url = "https://#{ENV['AWS_COGNITO_DOMAIN']}/oauth2/token"

        HTTParty.post(url, headers: headers, body: body)
      end
  end
end