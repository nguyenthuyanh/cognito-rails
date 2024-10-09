require "rails_helper"

RSpec.describe ::Pognito::Cognito, type: :lib do
  subject(:pognito) { described_class.client(storage: session) }

  let(:session) { { access_token: nil, refresh_token: nil } }
  let(:user) { { username: "Test User" } }
  let(:access_code) { "access_code" }
  let(:access_token) { "access_token" }
  let(:refresh_token) { "refresh_token" }

  describe "#store_tokens" do
    context "when it's first time sign in" do
      before do
        allow_any_instance_of(described_class).to receive(:fetch_tokens).and_return({
          "access_token" => access_token, "refresh_token" => refresh_token,
        })
      end

      it "fetch token from access code" do
        expect_any_instance_of(described_class).to receive(:fetch_tokens).with(access_code).once
        pognito.store_tokens(access_code)
      end

      it "save token on storage" do
        expect(pognito.store_tokens(access_code)).to eq({ access_token:, refresh_token: })
      end
    end

    context "when tokens exists" do
      let(:session) { { access_token:, refresh_token: } }

      it "do not fetch new token and return exists token" do
        expect_any_instance_of(described_class).not_to receive(:fetch_tokens)
        expect(pognito.store_tokens(access_code)).to eq({ access_token:, refresh_token: })
      end
    end
  end

  describe "#user" do
    context "when tokens is valid" do
      let(:new_access_token) { "new_access_token" }
      let(:user_response) do
        double(username: "username", user_attributes: [double(name: "email", value: "test@eversun.fr")])
      end

      before do
        allow_any_instance_of(described_class).to receive(:fetch_tokens).and_return({
          "access_token" => new_access_token,
        })
      end

      it "fetch new access token from refresh token" do
        expect_any_instance_of(described_class).to receive(:fetch_tokens).with(refresh_token,
          grant_type: "refresh_token").once
        pognito.user
      end

      it "fetch user info with new access token" do
        expect_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:get_user)
          .with({ access_token: new_access_token }).once
        pognito.user
      end

      it "return user info" do
        allow_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:get_user).and_return(user_response)
        expect(pognito.user).to eq({ username: "username", email: "test@eversun.fr" })
      end
    end

    context "when tokens is invalid" do
      it "delete old tokens and return nil" do
        expect_any_instance_of(described_class).to receive(:delete_tokens).once
        pognito.user
      end

      it { expect(pognito.user).to be_nil }
    end
  end

  describe "#sign_out" do
    context "with exists tokens" do
      let(:session) { { access_token:, refresh_token: } }

      it "call idp sign out method and delete exists tokens" do
        expect_any_instance_of(Aws::CognitoIdentityProvider::Client).to receive(:global_sign_out)
          .with({ access_token: }).once
        expect_any_instance_of(described_class).to receive(:delete_tokens).once

        pognito.sign_out
      end
    end
  end
end
