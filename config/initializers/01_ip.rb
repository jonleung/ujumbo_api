require 'resolv'
require 'debugger'
require 'webrick'

def canihazip_please
  response = HTTParty.get('http://ipv4.icanhazip.com')
  ip = response.body.gsub(/\s*/, "")
  if Resolv::IPv4::Regex.match(ip).present?
    return ip.to_s
  else
    raise "Unable to get ip address from icanhazip.com"
  end
end

def localtunnel_please
  require 'pty'
  require 'redis'
  require 'debugger'

  $redis = Redis.new
  redis_channel = "localtunnel:url"
  $redis.set(redis_channel, "")

  @port = Rails::Server.new.options[:Port].to_s

  $pid = fork do
    $redis = Redis.new

    cmd = "localtunnel #{@port}" 
    puts "RUNNING COMMAND #{cmd}"
    begin

      $pty = PTY.spawn( cmd ) do |stdin, stdout, pid|
        begin
          stdin.each do |line|
            puts line
            if !(localtunnel_url = line[/(http:\/\/.*?\.localtunnel\.com)/]).nil?
              $redis.set(redis_channel, localtunnel_url)
              break
            end
          end
        rescue Errno::EIO
          puts "Errno:EIO error, but this probably just means " +
                "that the process has finished giving output"
        end
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end
  end

  loop do 
    if (localtunnel_url = $redis.get(redis_channel) ).empty?
      print "Waiting for localtunnel"
      sleep 1
    else
      puts "localtunnel URL found: #{localtunnel_url}"
      return localtunnel_url
    end
    trap "INT" do exit end

  end

end

class CallbackServlet < WEBrick::HTTPServlet::AbstractServlet
  
  def do_GET(request, response)
    status, content_type, body = do_stuff_with(request)
    
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
    "shutting down servlet"
    @server.shutdown
  end
  
  def do_stuff_with(request)
    return 200, "application/json", "{status: \"success\"}"
  end
  
end


=begin

ip
  check ip+custom_port

localtunnel
  check localtunnel

=end

def ip_is_external?(ip)

  callback_echoer_url = "http://www.callbackmemaybe.com"

  servlet_port = 3334
  
  thread = Thread.new do
    @server = WEBrick::HTTPServer.new(:Port => servlet_port)
    @server.mount "/", CallbackServlet, "red", "2em"
    trap "INT" do @server.shutdown end
    @server.start
  end
  thread.run

  options = {
    query: {
      verb: "get",
      callback_url: "#{ip}:#{servlet_port}"
    }
  }

  begin
    http_party = HTTParty.get(callback_echoer_url, options)
    response = HashWithIndifferentAccess.new(JSON.parse(http_party.response.body))
    case response[:status]
    when "success"
      return true
    when "error"
      return false
    else
      raise "Unable to parse status #{response[:status]}"
    end

  rescue
    raise "Unable to connect with echocallback.com"
  end
end

def set_environment(base_url)
  ENV['base_url'] = base_url
  puts "ENV['base_url] = " + ENV['base_url'] 
end

def set_external_ip?
  ENV['set_external_ip'] == 'true'
end

if set_external_ip?
  raise "This only works in rails" unless defined?(Rails::Server)
  if (ip = canihazip_please) && ip_is_external?(ip)
    port = Rails::Server.new.options[:Port].to_s
    set_environment("http://#{ip}:#{port}")
  else
    puts "ERROR: Unable to automatically set your external ip!"
    puts "Please set your ENV['base_url'] here to a http://localtunnel address!"
    debugger
    puts "SET ENV['base_url'] = #{ENV['base_url']}"
  # else base_url = localtunnel_please
  #   set_environment(base_url) #assuming that icanhazip address works
  end
end