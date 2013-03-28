Ujumbo::Application.routes.draw do

  # API ROUTES
  root :to => redirect('/login')
  
  # Authentication
  match '/login' => redirect('/auth/google_oauth2')
  match '/auth/google_oauth2/callback' => 'google_docs#omniauth_success_callback'


  match 'triggers/:id' => 'trigger#activate'

  # match '/api' => 'api_controller#' 

  match '/google_docs/spreadsheet/create' => 'google_docs#create'

  match '/google_docs/row/create' => 'google_docs#create_row'
  
  # Google Docs Callbacks
  match "/google_docs/callback" => 'google_docs#callback'

  # Android Callbacks
  match "/android/sms/outbound/all" => "android_sms#all"
  match "/android/sms/outbound/update" => "android_sms#update"
  match "/android/sms/inbound/create" => "android_sms#create"

  match "/dropbox/choose" => "dropbox#index"
  match "/dropbox/trigger" => "dropbox#trigger"

  # CLIENT ROUTES
  

end
