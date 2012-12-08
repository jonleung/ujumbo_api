require 'httparty'

class ApiClient
  include HTTParty

  host = "localhost:3000"
  base_uri host
  HOST = host

  def initialize(options={})
    @user_token = options[:user_token]
    @client_token = options[:client_token]
    @name = options[:name]
  end

  def self.normalize_parameters(value)
    case value
    when Hash
      h = {}
      value.each { |k, v| h[k] = normalize_parameters(v) }
      h.with_indifferent_access
    when Array
      value.map { |e| normalize_parameters(e) }
    else
      value
    end
  end

  def post(endpoint, options={})
    begin
      result = self.class.post(
        endpoint,
        :body => options.to_json,
        :headers => { 'Content-Type' => 'application/json' },
        :timeout => 999999
      )
      response = ApiClient.normalize_parameters(result.parsed_response)
        `echo #{shell_escape(response.to_s)} | browser` if options[:debug] == "browser"
        pp response
      return response

    rescue Errno::ECONNREFUSED
      puts "Unable to connect to a rails server running on #{HOST}.".white.on_red
      puts "Are you sure you're running a rails server on #{HOST}?"
    end
  end

  def shell_escape(str) # for debugging and outputting website
    return "''" if str.empty?
    str = str.dup
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
    str.gsub!(/\n/, "'\n'")
    return str
  end

end