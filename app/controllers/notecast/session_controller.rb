class SessionController < ApplicationController

  def destroy
    if current_user.present?
      name = current_user.first_name
      flash[:notice] = "We'll see you later #{name}!"
      session[:user_id] = nil
    end
    redirect_to '/'
  end

end