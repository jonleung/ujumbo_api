module SendGrid
  def self.security_token
    @security_token = "rcAFrqpVJmmUea5QFyB8uw968Rphra-KWOibgX_1uDeA"
  end
end

ENV['main_email'] = 'send@modmail.cc'
ENV['hostname'] = 'modmail.cc'

if set_external_ip?

  raise "So you need to not do this SendGrid config stuff in production..." if Rails.env.production?

  callback_url = ENV['base_url']+"/api/sendgrid/callback?security_token=#{SendGrid.security_token}"

  options = { 
    body: nil, 
    query: {
      api_user: "modmail",
      api_key: "ayakasayslessismore",
      hostname: ENV['hostname'],
      url: callback_url
    } 
  }

  response = HTTParty.post("https://sendgrid.com/api/parse.delete.json", options).to_hash
  # raise "Unable to remove previous SendGrid callback!" if response["message"] != "success"

  response = HTTParty.post("https://sendgrid.com/api/parse.set.json", options).to_hash
  if response["message"] != "success"
    raise "Unable to send SendGrid callback url #{callback_url}\ninstead got: #{response}"
  else
    puts "Successfully set SendGrid URL to #{callback_url}"
  end

end