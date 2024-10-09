# frozen_string_literal: true

module PognitoConcern
  extend ActiveSupport::Concern

  private
    def pognito
      @pognito ||= Pognito::Cognito.client(storage: session)
    end

    def redirect_to_sign_in
      pognito.redirect_to_after_sign_in(request.url)
      redirect_to pognito.sign_in_url, allow_other_host: true
    end

    def redirect_to_sign_out
      redirect_to pognito.sign_out_url, allow_other_host: true
    end

    def redirect_to_root
      redirect_to root_path, allow_other_host: true
    end

    def current_user
      @current_user ||= pognito.user
    end

    def restrict_access
      return redirect_to_sign_in unless pognito.tokens?

      redirect_to_root unless current_user
    end
end
