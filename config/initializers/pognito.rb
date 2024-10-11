Rails.application.configure do
  config.to_prepare do
    Pognito::Config.setup do |conf|
      conf.region = ENV["AWS_COGNITO_REGION"]
      conf.access_key = ENV["AWS_ACCESS_KEY"]
      conf.host = ENV["AWS_COGNITO_DOMAIN"]
      conf.client_id = ENV["AWS_COGNITO_APP_CLIENT_ID"]
      conf.client_secret = ENV["AWS_COGNITO_APP_CLIENT_SECRET"]
      conf.redirect_uri = ENV["AWS_COGNITO_REDIRECT_URI"]
    end
  end
end
