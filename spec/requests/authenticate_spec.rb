require "rails_helper"

class FooBarController < ApplicationController
  def index
    render plain: "OK"
  end
end

Rails.application.routes.disable_clear_and_finalize = true
Rails.application.routes.draw do
  get "/foo_bar", to: "foo_bar#index"
end

RSpec.describe "Authenticate user with cognito IDP", type: :request do
  let(:cognito_login_url) { "http://cognito_login_url" }
  let(:user) { { username: "Test User" } }
  let(:access_token) { "access_token" }
  let(:refresh_token) { "refresh_token" }

  before do
    allow_any_instance_of(Pognito::Cognito).to receive(:sign_in_url).and_return(cognito_login_url)
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

        get "/foo_bar"
        expect(response).to be_successful
        expect(response).not_to have_http_status(:redirect)
        expect(assigns(:current_user)).to eq(user)
      end
    end
  end

  describe "GET /" do
    context "when user do not sign in" do
      it "returns http success" do
        get root_path
        expect(response).to be_successful
        expect(assigns(:current_user)).to be_nil
      end
    end

    context "when user is signed in" do
      it "returns http success" do
        allow_any_instance_of(Pognito::Cognito).to receive(:user).and_return(user)

        get root_path

        expect(response).to be_successful
        expect(assigns(:current_user)).to eq(user)
      end
    end
  end

  describe "GET /login" do
    context "when user not sign in" do
      it "redirect to Cognito login page" do
        allow_any_instance_of(Pognito::Cognito).to receive(:sign_in_url).and_return(cognito_login_url)

        get "/login"

        expect(response).to redirect_to cognito_login_url
      end
    end

    context "when user is redirect back to login page after signing in" do
      let(:access_code) { "access_code" }
      let(:redirect_url) { "/" }

      it "redirect to Cognito login page" do
        allow_any_instance_of(Pognito::Cognito).to receive(:access_token).and_return(access_token)
        allow_any_instance_of(Pognito::Cognito).to receive(:refresh_token).and_return(refresh_token)
        allow_any_instance_of(Pognito::Cognito).to receive(:redirect_to_after_sign_in).and_return(redirect_url)
        allow_any_instance_of(Pognito::Cognito).to receive(:user).and_return(user)

        get login_path(code: access_code)

        expect(response).to redirect_to redirect_url
      end
    end
  end
end
