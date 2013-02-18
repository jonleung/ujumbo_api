UjumboApi::Application.routes.draw do
  

  root :to => redirect('https://github.com/jonleung/ujumbo_api')
  match 'triggers/:id' => 'trigger#activate'
  # match '/api' => 'api_controller#' 


  # Google Docs Callbacks
  match "/google_docs/callback" => 'google_docs#callback'

  # Android Callbacks
  match "/android/sms/outbound/all" => "android_sms#all"
  match "/android/sms/outbound/update" => "android_sms#update"
  match "/android/sms/inbound/create" => "android_sms#create"
end
