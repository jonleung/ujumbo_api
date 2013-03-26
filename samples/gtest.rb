require 'google/api_client'
require 'launchy'

# Get your credentials from the APIs Console
CLIENT_ID = '437562178340.apps.googleusercontent.com'
CLIENT_SECRET = 'KCYeiLoRVTQe5pYLO_HR4j_F'
OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Create a new API client & load the Google Drive API 
client = Google::APIClient.new
drive = client.discovered_api('drive', 'v2')

# Request authorization
client.authorization.client_id = CLIENT_ID
client.authorization.client_secret = CLIENT_SECRET
client.authorization.scope = OAUTH_SCOPE
client.authorization.redirect_uri = REDIRECT_URI

uri = client.authorization.authorization_uri
Launchy.open(uri)

# Exchange authorization code for access token
$stdout.write  "Enter authorization code: "
client.authorization.code = gets.chomp
client.authorization.fetch_access_token!

def store_changes

end

def get_changes_array(client)
	drive = client.discovered_api('drive', 'v2')
	changes = client.execute(
		:api_method => drive.changes.list
	)
	if changes.data?
		return changes.data.items
	end
end

def get_changed_filenames(client)
	filenames = []
	changes = get_changes_array(client)
	changes.each do |change|
		filenames << change.file.title
	end
	return filenames
end

def get_changed_info(client)
	arr = []
	
	changes = get_changes_array(client)
	changes.each do |change|
		info = {}
		info[:filename] = change.file.title
		info[:time] = change.file.modifiedDate
		arr << info
	end 
	arr = arr.sort_by { |hsh| hsh[:time] }
	return arr
end

arr = get_changed_info(client)

puts arr