require "rails_helper"

module Dashboard
  class FooBarController < Dashboard::ApplicationController
    def index
      render plain: "OK"
    end
  end
end

Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  get "/foo_bar", to: "dashboard/foo_bar#index"
end

RSpec.describe "Authenticate user with cognito IDP", type: :request do
  let(:cognito_login_url) { "http://cognito_login_url" }
  let(:user) { build(:cognito_user) }
  let(:access_token) { "access_token" }
  let(:refresh_token) { "refresh_token" }

  before do
    allow(Pognito::Config).to receive(:sign_in_url).and_return(cognito_login_url)
  end

  describe "GET /foo_bar" do
    context "when user do not sign in" do
      it "redirect to login page" do
        get "/foo_bar"
        expect(response).to redirect_to(cognito_login_url)
      end
    end

    context "when user is signed in" do
      it "returns http success" do
        allow_any_instance_of(Pognito::Cognito).to receive(:user).and_return(user)
        allow_any_instance_of(Pognito::Cognito).to receive(:access_token).and_return(access_token)
        allow_any_instance_of(Pognito::Cognito).to receive(:refresh_token).and_return(refresh_token)
        allow_any_instance_of(UserServices::UpdateInfo).to receive(:call).and_return(create(:user))

        get "/foo_bar"
        expect(response).to be_successful
        expect(response).not_to have_http_status(:redirect)
        expect(assigns(:current_user)).to be_a User
      end
    end
  end

  describe "GET /login" do
    context "when user not sign in" do
      it "redirect to Cognito login page" do
        get "/login"

        expect(response).to redirect_to cognito_login_url
      end
    end

    context "when user is redirect back to login page after signing in on Idp" do
      let(:access_code) { "access_code" }
      let(:redirect_url) { "/" }

      it "redirect to Cognito login page" do
        allow_any_instance_of(Pognito::Cognito).to receive(:access_token).and_return(access_token)
        allow_any_instance_of(Pognito::Cognito).to receive(:refresh_token).and_return(refresh_token)
        allow_any_instance_of(Pognito::Cognito).to receive(:after_sign_in_path).and_return(redirect_url)
        allow_any_instance_of(Pognito::Cognito).to receive(:user).and_return(user)

        get login_path(code: access_code)

        expect(response).to redirect_to redirect_url
      end
    end
  end

  describe "GET /logout" do
    let(:cognito_logout_url) { "http://cognito_logout_url" }

    before do
      allow(Pognito::Config).to receive(:sign_out_url).and_return(cognito_logout_url)
    end

    it "redirect to Cognito logout page" do
      get "/logout"

      expect(response).to redirect_to cognito_logout_url
    end
  end
end
