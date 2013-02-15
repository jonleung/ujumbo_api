require 'google/api_client'
require 'launchy'
require 'openssl'
 
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
def authenticate
	cid = '437562178340.apps.googleusercontent.com'
	csecret = 'KCYeiLoRVTQe5pYLO_HR4j_F'
	ruri = 'urn:ietf:wg:oauth:2.0:oob'
	client = Google::APIClient.new
	drive = client.discovered_api('drive', 'v2')

	client.authorization.client_id = cid
	client.authorization.client_secret = csecret
	client.authorization.scope = 'https://www.googleapis.com/auth/drive'
	client.authorization.redirect_uri = ruri
	
	uri = client.authorization.authorization_uri
	#Launchy.open(uri)

	#client.authorization.code = gets.chomp
	

	client.authorization.code = '4/M9DBkxrLn6hQPMoodKRe4O9lb5yC.EqfodAg71goQaDn_6y0ZQNgKn8gteQI'
	client.authorization.fetch_access_token!
	result = Array.new
	  page_token = nil
	  begin
	    parameters = {}
	    if page_token.to_s != ''
	      parameters['pageToken'] = page_token
	    end
	    api_result = client.execute(
	      :api_method => drive.files.list,
	      :parameters => parameters)
	    if api_result.status == 200
	      files = api_result.data
	      result.concat(files.items)
	    else
	      puts "An error occurred: #{result.data['error']['message']}"
	      page_token = nil
	    end
	  end while page_token.to_s != ''
	  result
end

a = authenticate
puts a