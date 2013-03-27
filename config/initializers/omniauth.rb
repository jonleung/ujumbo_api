OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider OmniAuth::Strategies::GoogleOauth2, "437562178340.apps.googleusercontent.com", "KCYeiLoRVTQe5pYLO_HR4j_F"
end
