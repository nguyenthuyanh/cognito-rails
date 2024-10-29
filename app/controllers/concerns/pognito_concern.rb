# frozen_string_literal: true

module PognitoConcern
  extend ActiveSupport::Concern

  private
    def authenticate_user
      return if pognito.tokens? && current_user

      redirect_to_sign_in
    end

    def pognito
      @pognito ||= Pognito::Cognito.client(storage: session)
    end

    def current_user
      @current_user ||= UserServices::UpdateInfo.call(
        object: User.find_or_initialize_by(uuid: pognito.user["sub"]),
        params: pognito.user
      ).user
    end

    def redirect_to_sign_in
      pognito.after_sign_in_path(request.url)

      redirect_to Pognito::Config.sign_in_url, allow_other_host: true
    end

    def redirect_to_sign_out
      pognito.sign_out

      redirect_to Pognito::Config.sign_out_url, allow_other_host: true
    end
end
