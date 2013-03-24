class DropboxController < ApplicationController

  def index
    session[:product_id] = @product_id
    #this gives you the page where the user logs in and selects the file
  end

  def trigger
    Trigger.trigger(session[:product_id], "dropbox:file:add", params[:dropbox_params])
  end

end