class WelcomeController < ApplicationController

  def index
    redirect_to "/spreadsheets" if current_user
  end

end