class Api::GoogleDocsController < ApiController
  
  before_filter :ensure_user, only: [:create, :create_row]

  def omniauth_success_callback
    data = HashWithIndifferentAccess.new(request.env["omniauth.auth"])
    
    user_params = HashWithIndifferentAccess.new
    user_params[:google_uid] = data[:uid]
    user_params[:email] = data[:info][:email]
    user_params[:first_name] = data[:info][:first_name]
    user_params[:last_name] = data[:info][:last_name]
    user_params[:photo] = data[:info][:image]

    user_params[:verified_email] = data[:extra][:raw_info][:verified_email]
    user_params[:google_plus] = data[:extra][:raw_info][:link]
    user_params[:gender] = data[:extra][:raw_info][:gender]
    user_params[:locale] = data[:extra][:raw_info][:locale]

    credential_params = HashWithIndifferentAccess.new
    credential_params[:token] = data[:credentials][:token]
    credential_params[:refresh_token] = data[:credentials][:refresh_token]
    credential_params[:expires_at] = data[:credentials][:expires_at]
    credential_params[:expires] = data[:credentials][:expires]

    omniauth_params = {
      :user_params => user_params,
      :credential_params => credential_params,
    }
    user = User.from_omniauth(omniauth_params)

    render :json => user.to_json
  end

  #TODO
  def omniauth_failure_callback 
    redirect_to "https://github.com/images/error/octocat_sad.gif"
  end

  def callback
    # TODO, each script needs to have unique security tokens inside of it or else anyone can fake these
    # therefore need to programatically edit script
    doc = GoogleDoc.where(key: params['key']).first
  	changes = doc.trigger_changes
    puts changes
  end

  def create
    google_doc = GoogleDoc.create(params)
    render json: google_doc.to_json
  end

  def create_row
    doc = GoogleDoc.find(params[:file_id])             # want to get by id, not filename
    doc.create_row(params[:row])
    render text: true
  end
end
