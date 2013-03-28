class GoogleCredential
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :token, type: String
  field :refresh_token, type: String
  field :expires_at, type: Integer
  field :expires, type: Boolean
  
  embedded_in :user

  # http://stackoverflow.com/questions/12572723/rails-google-client-api-unable-to-exchange-a-refresh-token-for-access-token
  
  def refresh
    debugger
    data = {
      :client_id => ENV['GOOGLE_KEY'],
      :client_secret => ENV['GOOGLE_SECRET'] ,
      :refresh_token => self.refresh_token,
      :grant_type => "refresh_token"
    }
    
    options = { :body => data, :query => {} }
    response = HTTParty.post("https://accounts.google.com/o/oauth2/token", options).to_hash
    debugger
    if (new_token = response["access_token"]).present?
      self.token = new_token
      self.expires_at = response["expires_at"]
      self.save
    else
      # No Token
      raise "Token could not be refreshed"
    end
  end
  
end