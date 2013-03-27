OmniAuth.config.logger = Rails.logger

ENV['GOOGLE_KEY'] = "437562178340.apps.googleusercontent.com"
ENV['GOOGLE_SECRET'] = "KCYeiLoRVTQe5pYLO_HR4j_F"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {
    :scope => "https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/drive.file,https://mail.google.com/,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/userinfo.profile",
    :approval_prompt => "auto"
  }
end
