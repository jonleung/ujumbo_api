account_sid = 'ACc458afd493c7ad55a6da08b2df28f56d'
auth_token = 'eee531456e7c25281a30b23d07866e89'

$twilio = Twilio::REST::Client.new account_sid, auth_tokenUJUMBO_PHONE = "+14842380812"

module Twilio
  DEFAULT_PHONE = "+14842380812" #TODO make this a real number so that you can make calls
end