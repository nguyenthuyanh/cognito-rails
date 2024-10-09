module Pognito
  class Config
    class << self
      attr_accessor :region,
        :access_key,
        :host,
        :client_id,
        :client_secret,
        :redirect_uri,
        :endpoints,
        :scope

      def setup
        @endpoints = {
          authorize: "/oauth2/authorize",
          token: "/oauth2/token",
          logout: "/logout",
        }

        @scope = ["email", "openid", "phone", "aws.cognito.signin.user.admin"]

        yield self
      end

      def header
        {
          Authorization: "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}",
          "Content-Type": "application/x-www-form-urlencoded",
        }
      end

      def sign_in_url
        URI::HTTPS.build(host:, path: endpoints[:authorize], query: {
          response_type: :code,
          client_id:,
          scope: scope.join(" "),
          redirect_uri: "#{redirect_uri}/login",
        }.to_query).to_s
      end

      def sign_out_url
        URI::HTTPS.build(host:, path: endpoints[:logout], query: {
          client_id:,
          logout_uri: "#{redirect_uri}/",
        }.to_query).to_s
      end
    end
  end
end
