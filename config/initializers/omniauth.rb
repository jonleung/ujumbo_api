OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new do |env|
  "GoogleDocsController".constantize.action(:omniauth_failure_callback).call(env)
end

ENV['GOOGLE_KEY'] = "437562178340.apps.googleusercontent.com"
ENV['GOOGLE_SECRET'] = "KCYeiLoRVTQe5pYLO_HR4j_F"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {
    :scope => "https://www.googleapis.com/auth/userinfo.profile,https://www.googleapis.com/auth/userinfo.email,https://docs.google.com/feeds,https://docs.googleusercontent.com,https://spreadsheets.google.com/feeds",
    :approval_prompt => "auto"
  }
end

#TODO, add back persmission