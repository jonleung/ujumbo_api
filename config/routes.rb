UjumboApi::Application.routes.draw do
  root :to => redirect('https://github.com/jonleung/ujumbo_api')
  match 'triggers/:id' => 'trigger#activate'
  # match '/api' => 'api_controller#' 

  match "/android/sms/outbound/all" => "android_sms#all"
  match "/android/sms/outbound/update" => "android_sms#update"
  match "/android/sms/inbound/create" => "android_sms#create"

  match "/dropbox/choose" => "dropbox#index"
  match "/dropbox/trigger" => "dropbox#trigger"

end
