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

    def sign_out
      return unless tokens?

      begin
        @client.global_sign_out({ access_token: })
        unset_tokens
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        # silence revoked token errors
      end
    end

    def tokens?
      access_token && refresh_token
    end

    def after_sign_in_path(url=nil)
      storage[:redirect_to] = url if url

      storage[:redirect_to]
    end

    # def redirect_to_after_sign_in(url=nil)
    #   storage[:redirect_to] = url if url

    #   storage[:redirect_to]
    # end

    # def clear_redirect_to_after_sign_in
    #   storage.delete(:redirect_to)
    # end

    private
      def refresh_access_token
        new_tokens = tokens_from(refresh_token, grant_type: "refresh_token")

        storage[:access_token] = new_tokens["access_token"]

        { access_token: }
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

      def tokens_from(code, grant_type: "authorization_code")
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
