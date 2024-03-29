Ujumbo::Application.routes.draw do

  root :to => 'welcome#index'
  match 'login' => redirect('/auth/google_oauth2')
  match '/logout' => 'session#destroy', as: 'logout'
  match '/auth/google_oauth2/callback' => 'api/google_docs#omniauth_success_callback'

  match '/d' => 'debugger#index'
  match '/n' => 'debugger#n'

  resources :spreadsheets

  namespace :api do

    # AUTHENTICATION
    match '/login' => redirect('/auth/google_oauth2')
    match '/auth/google_oauth2/callback' => 'api/google_docs#omniauth_success_callback'

    get '/pipelines/create' => 'pipelines#create'

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

    # SendGrid
    match "/sendgrid/callback" => "sendgrid#callback"
  
  end

end
