class Client::ClientController < ActionController::Base

  def index
    render template: "client/index"
  end

end