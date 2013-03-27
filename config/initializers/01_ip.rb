require 'resolv'

response = HTTParty.get('http://icanhazip.com')
ip = response.body.gsub(/\s*/, "")
if Resolv::IPv4::Regex.match(ip).present?
  ENV["ip"] = ip
  begin
    port = Rails::Server.new.options[:Port]
  rescue
    port = "3000"
  end

  ENV["base_url"] = "http://#{ip}:#{port}"
else
  raise "Unable to determine ip address by doing GET icanhazip.com"
end