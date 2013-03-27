class GoogleDocsController < ApplicationController
  
  def omniauth_callback
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

    credentials_params = HashWithIndifferentAccess.new
    credentials_params[:token] = data[:credentials][:token]
    credentials_params[:refresh_token] = data[:credentials][:refresh_token]
    credentials_params[:expires_at] = data[:credentials][:expires_at]
    credentials_params[:expires] = data[:credentials][:expires]

    user = User.create(user_params)
    user.google_credential = GoogleCredential.new(credentials_params)

    render :json => user.google_credential.to_json
  end

  def callback
    doc = GoogleDoc.where(key: params['key']).first
  	changes = doc.trigger_changes
    puts changes
  end

  def create
    google_doc = GoogleDoc.new(params)
    render json: google_doc.to_json
  end

  def create_row
    doc = GoogleDoc.find(params[:file_id])             # want to get by id, not filename
    doc.create_row(params[:row])
    render text: true
  end
end
