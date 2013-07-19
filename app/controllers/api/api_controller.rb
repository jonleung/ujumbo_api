class ApiController < ActionController::Base

  def ensure_user
    user_id = params[:user_id]
    if user_id.nil?
      render_error "No user_id is present" 
    else
      @user = User.find(user_id)
      render_error "The specified user with id #{user_id} could not be found" if @user.nil?
    end
  end

  def render_error(msg=nil, code=nil, &block)
    msg ||= 'error'
    code ||= 404
    if is_error = block_given? ? yield : true
      render :json=>{ :error => { :message=>msg, :code=>code } }
      true
    end
  end

  alias_method :render_error_if, :render_error
   
  def render_success(msg=nil, &block)
    msg ||= 'success'
    if success = block_given? ? yield : true
      render :json=> { :result => { :message=>msg } }
      true
    end
  end

end
