class PognitoController < ApplicationController
  include PognitoConcern

  def login
    if params[:code]
      pognito.store_tokens(params[:code])

      return redirect_to_after_sign_in
    end

    return redirect_to_sign_in unless pognito.tokens?

    redirect_to_after_sign_in
  end

  def logout
    redirect_to_sign_out
  end

  private
    def redirect_to_after_sign_in
      redirect_to pognito.after_sign_in_path || dashboard_root_path
    end
end
