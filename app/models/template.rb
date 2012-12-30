class Template
  include ActiveModel
  
  DEFAULT_VARIABLE_REGEX = /:::(.*?):::/

  attr_accessor :text, :variable_regex

  def initialize(text, variable_regex=DEFAULT_VARIABLE_REGEX) 
    debugger
    @text = text
    @variable_regex = variable_regex.nil? ? DEFAULT_VARIABLE_REGEX : variable_regex
  end

  def fill(hash)
    debugger
    self.text.gsub!(self.variable_regex) { hash[$1.to_sym] }
  end

  def variables
    self.text.scan(variable_regex).map { |match| match[0].to_sym }
  end

end