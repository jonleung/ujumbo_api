require 'httparty'

class ApiClient
  include HTTParty

  puts "LOADED ApiClient"

  base_uri "localhost:3000"

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
        :body => options#.merge({:access_token=>@user_token, :api_key=>@client_token}).to_json, 
        :headers => { 'Content-Type' => 'application/json' },
        :timeout => 999999
      )
      ApiClient.normalize_parameters(result.parsed_response)
    rescue Errno::ECONNREFUSED
      puts "Unable to connect to a rails server running on #{HOST}.".white.on_red
      puts "Are you sure you're running a rails server on #{HOST}?"
    end
  end
end