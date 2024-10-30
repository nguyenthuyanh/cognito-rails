# frozen_string_literal: true

module Pognito
  class Cognito
    attr_reader :storage

    def self.client(storage:)
      @client ||= Aws::CognitoIdentityProvider::Client.new(
        region: Config.region,
        access_key_id: Config.access_key,
        secret_access_key: Config.client_secret
      )

      self.new(storage:, client: @client)
    end

    def initialize(storage:, client:)
      @storage = storage
      @client = client
    end

    def user
      return unless tokens?

      begin
        refresh_access_token

        user = @client.get_user({ access_token: }) if access_token
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        user = nil
      end

      unless user
        delete_tokens

        return nil
      end

      user.user_attributes.inject({}) do |h, attr|
        h.merge(attr.name => attr.value)
      end.merge("username" => user.username)
    end

    def store_tokens(access_code)
      unless tokens?
        new_tokens = fetch_tokens(access_code)

        storage[:access_token] = new_tokens["access_token"]
        storage[:refresh_token] = new_tokens["refresh_token"]
      end

      { access_token:, refresh_token: }
    end

    def sign_out
      return unless tokens?

      begin
        @client.global_sign_out({ access_token: })
        delete_tokens
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        # silence revoked token errors
      end
    end

    def tokens?
      access_token && refresh_token
    end

    def after_sign_in_path(url=nil)
      if url.present?
        storage[:redirect_to] = url
      else
        url = storage[:redirect_to]
        storage.delete(:redirect_to)
      end

      url
    end

    private
      def refresh_access_token
        new_tokens = fetch_tokens(refresh_token, grant_type: "refresh_token")

        storage[:access_token] = new_tokens["access_token"]

        { access_token: }
      end

      def delete_tokens
        storage.delete(:access_token)
        storage.delete(:refresh_token)
      end

      def access_token
        storage[:access_token]
      end

      def refresh_token
        storage[:refresh_token]
      end

      def fetch_tokens(code, grant_type: "authorization_code")
        body = {
          grant_type:,
          client_id: Config.client_id,
          redirect_uri: "#{Config.redirect_uri}/login",
        }.merge(grant_type == "authorization_code" ? { code: } : { refresh_token: code })

        url = URI::HTTPS.build(host: Config.host, path: Config.endpoints[:token])

        HTTParty.post(url, headers: Config.header, body:)
      end
  end
end
