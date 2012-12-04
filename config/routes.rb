UjumboApi::Application.routes.draw do
  root :to => redirect('https://github.com/jonleung/ujumbo_api')
  match 'pipelines/:id/call' => 'pipeline#call'
  # match '/api' => 'api_controller#' 
end
