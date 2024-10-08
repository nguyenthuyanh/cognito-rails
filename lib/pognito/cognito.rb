# frozen_string_literal: true

module Pognito
  class Cognito
    attr_reader :storage

    def self.client(storage:)
      @client ||= Aws::CognitoIdentityProvider::Client.new(
        region: ENV["AWS_COGNITO_REGION"],
        access_key_id: ENV["AWS_ACCESS_KEY"],
        secret_access_key: ENV["AWS_SECRET_KEY"]
      )

      @storage ||= storage

      self.new(storage: @storage, client: @client)
    end

    def initialize(storage:, client:)
      @storage = storage
      @client = client
    end

    def user
      begin
        refresh_access_token

        user = @client.get_user({ access_token: }) if access_token
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

    def tokens(code)
      unless tokens?
        new_tokens = tokens_from(code)

        storage[:access_token] = new_tokens["access_token"]
        storage[:refresh_token] = new_tokens["refresh_token"]
      end

      { access_token:, refresh_token: }
    end

    def sign_in_url
      URI::HTTPS.build(host: ENV["AWS_COGNITO_DOMAIN"], path: "/oauth2/authorize", query: {
        response_type: :code,
        client_id: ENV["AWS_COGNITO_APP_CLIENT_ID"],
        scope: ["email", "openid", "phone", "aws.cognito.signin.user.admin"].join(" "),
        redirect_uri: "#{ENV["AWS_COGNITO_REDIRECT_URI"]}/login",
      }.to_query).to_s
    end

    def sign_out
      return unless tokens?

      begin
        @client.global_sign_out({ access_token: })
        unset_tokens
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        # silence revoked token errors
      end
    end

    def sign_out_url
      URI::HTTPS.build(host: ENV["AWS_COGNITO_DOMAIN"], path: "/logout", query: {
        client_id: ENV["AWS_COGNITO_APP_CLIENT_ID"],
        logout_uri: "#{ENV["AWS_COGNITO_REDIRECT_URI"]}/",
      }.to_query).to_s
    end

    def tokens?
      access_token && refresh_token
    end

    def redirect_to_after_sign_in(url=nil)
      storage[:redirect_to] = url if url

      storage[:redirect_to]
    end

    def clear_redirect_to_after_sign_in
      storage.delete(:redirect_to)
    end

    private
      def refresh_access_token
        new_tokens = tokens_from(refresh_token, grant_type: "refresh_token")

        storage[:access_token] = new_tokens["access_token"]

        { access_token: }
      end

      def encoded_client_credentials
        Base64.strict_encode64(
          "#{ENV["AWS_COGNITO_APP_CLIENT_ID"]}:#{ENV["AWS_COGNITO_APP_CLIENT_SECRET"]}"
        )
      end

      def unset_tokens
        storage.delete(:access_token)
        storage.delete(:refresh_token)
      end

      def access_token
        storage[:access_token]
      end

      def refresh_token
        storage[:refresh_token]
      end

      def tokens_from_refresh_token(refresh_token)
        tokens_from(refresh_token, grant_type: "refresh_token")
      end

      def tokens_from(code, grant_type: "authorization_code")
        headers = {
          Authorization: "Basic #{encoded_client_credentials}",
          "Content-Type": "application/x-www-form-urlencoded",
        }

        body = {
          grant_type:,
          client_id: ENV["AWS_COGNITO_APP_CLIENT_ID"],
          redirect_uri: "#{ENV["AWS_COGNITO_REDIRECT_URI"]}/login",
        }.merge(grant_type == "authorization_code" ? { code: } : { refresh_token: code })

        url = URI::HTTPS.build(host: ENV["AWS_COGNITO_DOMAIN"], path: "/oauth2/token")

        HTTParty.post(url, headers:, body:)
      end
  end
end
