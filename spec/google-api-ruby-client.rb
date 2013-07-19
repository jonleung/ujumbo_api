    # Initialize the client & Google+ API
    require 'google/api_client'
    client = Google::APIClient.new
    plus = client.discovered_api('plus')

    # Initialize OAuth 2.0 client    
    client.authorization.client_id = '306831549813.apps.googleusercontent.com'
    client.authorization.client_secret = 'zCgNEIUkUVpaZrLovwXgNDH3'
    client.authorization.redirect_uri = 'http://localhost/oauth2callback'
    
    client.authorization.scope = 'https://www.googleapis.com/auth/drive.scripts'

    # Request authorization
    redirect_uri = client.authorization.authorization_uri

    # Wait for authorization code then exchange for token
    client.authorization.code = '....'
    client.authorization.fetch_access_token!

    # Make an API call
    result = client.execute(
      :api_method => plus.activities.list,
      :parameters => {'collection' => 'public', 'userId' => 'me'}
    )

    puts result.data