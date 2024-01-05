class PognitoController < ApplicationController
  include PognitoConcern

  def login
    if params[:code]
      pognito.tokens(params[:code]); return redirect_to_after_sign_in
    end

    return redirect_to_sign_in unless pognito.tokens?

    redirect_to_after_sign_in
  end

  def logout
    pognito.sign_out

    redirect_to_sign_out
  end

  def redirect_to_after_sign_in
    url = pognito.redirect_to_after_sign_in
    pognito.clear_redirect_to_after_sign_in

    redirect_to url || root_path, allow_other_host: true
  end
end