require 'httparty'
require 'show_in_browser'

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

  def post(endpoint, params={}, options={debug: false})
    begin
      result = self.class.post(
        endpoint,
        :body => params.to_json,
        :headers => { 'Content-Type' => 'application/json' },
        :timeout => 999999
      )
      response = ApiClient.normalize_parameters(result.parsed_response)
      show_in_browser(response) if options[:debug] == true
      pp response
      return response

    rescue Errno::ECONNREFUSED
      puts "Unable to connect to a rails server running on #{HOST}.".white.on_red
      puts "Are you sure you're running a rails server on #{HOST}?"
    end
  end

  def show_in_browser(response)
    format = nil
    body = nil

    if response[0] == "<"
      format = ".html"
      body = response
    else
      format = ".json"
      body = response.to_json
    end
    ShowInBrowser.show(body, format)
  end

end