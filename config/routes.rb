UjumboApi::Application.routes.draw do
  

  root :to => redirect('https://github.com/jonleung/ujumbo_api')
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

end
