class PognitoController < ApplicationController
  skip_before_action :restrict_access
  def login
    pognito.tokens(params[:code])
    return redirect_to_after_sign_in if params[:code]

    return redirect_to_sign_in unless pognito.tokens?

    redirect_to_after_sign_in
  end

  def logout
    pognito.sign_out

    redirect_to_sign_out
  end

  private
    def redirect_to_after_sign_in
      url = pognito.redirect_to_after_sign_in
      pognito.clear_redirect_to_after_sign_in

      redirect_to url || root_path
    end
end
