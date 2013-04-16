OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new do |env|
  "GoogleDocsController".constantize.action(:omniauth_failure_callback).call(env)
end

ENV['GOOGLE_KEY'] = "130142805486.apps.googleusercontent.com"
ENV['GOOGLE_SECRET'] = "4U4C2jFXQC84Aydy2XBogbKQ"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {
    :scope => "https://www.googleapis.com/auth/userinfo.profile,https://www.googleapis.com/auth/userinfo.email,https://docs.google.com/feeds,https://docs.googleusercontent.com,https://spreadsheets.google.com/feeds",
    :approval_prompt => "auto"
  }
end

#TODO, add back persmission