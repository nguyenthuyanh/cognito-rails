#frozen_string_literal: true

module Cognito
  class Cognito
    @client = Aws::CognitoIdentityProvider::Client.new(
      region: ENV['AWS_COGNITO_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )

    def self.get_user(access_token)
      begin
        @client.get_user({access_token: access_token}) if access_token
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        nil
      end
    end

    def self.sign_in_url
      url = "https://#{ENV['AWS_COGNITO_DOMAIN']}/oauth2/authorize"

      "#{url}?response_type=code" \
        "&client_id=#{ENV['AWS_COGNITO_APP_CLIENT_ID']}" \
        "&scope=#{scope("email", "openid", "phone", "aws.cognito.signin.user.admin")}" \
        "&redirect_uri=#{ENV['AWS_COGNITO_REDIRECT_URI']}/login"
    end

    def self.tokens_from_code(code)
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

    def self.sign_out(access_token)
      begin
        @client.global_sign_out({access_token: access_token})
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        # silence revoked token errors
      end
    end

    def self.sign_out_url
      "https://#{ENV['AWS_COGNITO_DOMAIN']}/logout" \
        "?client_id=#{ENV['AWS_COGNITO_APP_CLIENT_ID']}" \
        "&logout_uri=#{ENV['AWS_COGNITO_REDIRECT_URI']}/"
    end

    private
      def self.scope(*args)
        args.join('+')
      end

      def self.encoded_client_credentials
        Base64.strict_encode64("#{ENV['AWS_COGNITO_APP_CLIENT_ID']}:#{ENV['AWS_COGNITO_APP_CLIENT_SECRET']}")
      end
  end
end