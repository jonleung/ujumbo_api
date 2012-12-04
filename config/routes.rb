UjumboApi::Application.routes.draw do
  root :to => redirect('https://github.com/jonleung/ujumbo_api')
  match 'triggers/:id' => 'trigger#activate'
  # match '/api' => 'api_controller#' 
end
