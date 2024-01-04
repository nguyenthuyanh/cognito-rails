class IndexController < ApplicationController
  def login
    set_tokens and return redirect_to root_path if params[:code] && !tokens?

    unless tokens?
      return redirect_to_sign_in
    end

    redirect_to root_path
  end

  def index
    render locals: { current_user: }
  end

  def user
    return redirect_to_sign_in unless tokens?

    return redirect_to root_path unless current_user

    render locals: { current_user: }
  end

  def logout
    if tokens?
      Cognito::Cognito.sign_out(access_token)
      unset_tokens
    end

    return redirect_to_sign_out
  end

  private
    def current_user
      @current_user ||= -> {
        user = Cognito::Cognito.get_user(access_token)

        unless user
          unset_tokens

          return nil
        end

        {
          username: user.username,
        }.merge(user.user_attributes.map { |attr| [attr.name, attr.value] }.to_h.symbolize_keys)
      }.call
    end

    def redirect_to_sign_in
      redirect_to Cognito::Cognito.sign_in_url, allow_other_host: true
    end

    def redirect_to_sign_out
      redirect_to Cognito::Cognito.sign_out_url, allow_other_host: true
    end

    def set_tokens
      tokens = Cognito::Cognito.tokens_from_code(params[:code])

      session[:access_token] = tokens["access_token"]
      session[:refresh_token] = tokens["refresh_token"]
    end

    def unset_tokens
      session.delete(:access_token)
      session.delete(:refresh_token)
    end

    def tokens?
      access_token && refresh_token
    end

    def access_token
      session[:access_token]
    end

    def refresh_token
      session[:refresh_token]
    end
end
