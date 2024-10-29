Rails.application.configure do
  config.to_prepare do
    Crm::Pennylane.setup do |conf|
      conf.host = "app.pennylane.com"
      conf.api_path = "/api/external/v1"
      conf.api_token = ENV["PENNYLAND_TOKEN_API"]
    end
  end
end
