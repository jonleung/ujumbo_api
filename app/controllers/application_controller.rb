class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def ensure_current_user(path=nil)
    return true if @current_user.present?

    if path.nil?
      redirect_to "/login"
    else
      redirect_to "/login", then_redirect_to: path
    end
    
  end

  alias :ensure_current_user_before :ensure_current_user

end
