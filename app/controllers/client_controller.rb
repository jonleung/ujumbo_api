class ClientController < ApplicationController

  def index
  end

  def index1
  	redirect_to('/home') if current_user
  end

  def sample
  end

end