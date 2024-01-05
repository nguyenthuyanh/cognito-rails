class IndexController < ApplicationController
  def login
    if params[:code] && !pognito.tokens?
      pognito.set_tokens(params[:code]); return redirect_to root_path
    end

    return redirect_to_sign_in unless pognito.tokens?

    redirect_to root_path
  end

  def index
    render locals: { current_user: }
  end

  def user
    return redirect_to_sign_in unless pognito.tokens?

    return redirect_to root_path unless current_user

    render locals: { current_user: }
  end

  def logout
    pognito.sign_out

    return redirect_to_sign_out
  end

  private
    def pognito
      @pognito ||= Pognito::Cognito.client(storage: session)
    end

    def redirect_to_sign_in
      redirect_to pognito.sign_in_url, allow_other_host: true
    end

    def redirect_to_sign_out
      redirect_to pognito.sign_out_url, allow_other_host: true
    end

    def current_user
      pognito.user
    end
end
