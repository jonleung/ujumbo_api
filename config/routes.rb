Ujumbo::Application.routes.draw do

  # API ROUTES
  root :to => redirect('/login')
  
  # Authentication
  match '/login' => redirect('/auth/google_oauth2')
  match '/auth/google_oauth2/callback' => 'google_docs#omniauth_success_callback'


  # DATASOURCES
  match '/google_docs/spreadsheet/create' => 'google_docs#create'
  
  # TRIGGERS

  # API Trigger
  match 'triggers/:id' => 'trigger#activate'

  # Google Docs Callbacks
  match "/google_docs/callback" => 'google_docs#callback'

  # Android Callbacks
  match "/android/sms/outbound/all" => "android_sms#all"
  match "/android/sms/outbound/update" => "android_sms#update"
  match "/android/sms/inbound/create" => "android_sms#create"

  # Twilio
  match "/twilio/sms" => 'twilio#sms_receive'
  match "/twilio/voice" => 'twilio#voice_receive'

  # CLIENT ROUTES
  

end
