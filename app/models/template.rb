class Template
  include ActiveModel
  
  DEFAULT_VARIABLE_REGEX = /:::(.*?):::/

  attr_accessor :text, :variable_regex

  def initialize(text, variable_regex=DEFAULT_VARIABLE_REGEX) 
    @text = text
    @variable_regex = variable_regex.nil? ? DEFAULT_VARIABLE_REGEX : variable_regex
  end

  def fill(hash)
    self.text.gsub!(self.variable_regex) { hash[$1.to_sym] }
  end

end