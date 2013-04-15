class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  def ensure_current_user(path=nil)
    return true if current_user
    if path.nil?
      redirect_to "/login"
    else
      redirect_to "/login", then_redirect_to: path
    end
    
  end

  alias :ensure_current_user_before :ensure_current_user

end
