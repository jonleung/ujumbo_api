Ujumbo::Application.routes.draw do

  root :to => 'client#index1'
  match '/home' => 'client#home'

  match '/sample' => 'client#sample'

  #match "/spreadsheets" => 'spreadsheet#index'
  #match "/spreadsheets/index" => 'spreadsheet#index'

  # match "/spreadsheets/create" => 'spreadheet#create' #Stick with RESTful Convetions
  # match "/spreadsheets/:id" => 'spreadsheet#get'
  # match "/spreadsheets/:id/get" => 'spreadsheet#get'
  # match "/spreadsheets/:id/update" => 'spreadsheet#update'
  # match "/spreadsheets/:id/destroy" => 'spreadsheet#destroy'
  match '/auth/google_oauth2/callback' => 'api/google_docs#omniauth_success_callback'

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
  
  end

end
