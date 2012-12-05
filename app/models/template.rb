require 'active_model'

class Template
  DEFAULT_VARIABLE_REGEX = /:::(.*?):::/

  attr_accessor :text, :variable_regex

  def initialize(text, variable_regex=DEFAULT_VARIABLE_REGEX)
    @text = text
    @variable_regex = variable_regex
  end

  def fill(hash)
    self.text.gsub!(variable_regex) { hash[$1.to_sym] }
  end

  def variables
    self.text.scan(variable_regex).map { |match| match[0].to_sym }
  end

end