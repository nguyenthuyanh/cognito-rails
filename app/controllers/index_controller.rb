class IndexController < ApplicationController
  def login
    if params[:code] && !pognito_client.tokens?
      pognito_client.set_tokens(params[:code]); return redirect_to root_path
    end

    return redirect_to_sign_in unless pognito_client.tokens?

    redirect_to root_path
  end

  def index
    render locals: { current_user: }
  end

  def user
    return redirect_to_sign_in unless pognito_client.tokens?

    return redirect_to root_path unless current_user

    render locals: { current_user: }
  end

  def logout
    pognito_client.sign_out

    return redirect_to_sign_out
  end

  private
    def pognito_client
      @pognito_client ||= Pognito::Cognito.client(storage: session)
    end

    def redirect_to_sign_in
      redirect_to pognito_client.sign_in_url, allow_other_host: true
    end

    def redirect_to_sign_out
      redirect_to pognito_client.sign_out_url, allow_other_host: true
    end

    def current_user
      pognito_client.user
    end
end
