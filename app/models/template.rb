# TODO, should precompute variables and only change them if text changes.

class Template < Ujumbo::UjumboRecord::Base
  include Redis::Objects

  DEFAULT_VARIABLE_REGEX = /:::(.*?):::/

  attr_accessible :text, :variable_regex
  after_initialize :set_default_variable_regex

  def fill(hash)
    self.text.gsub!(variable_regex) { hash[$1.to_sym] }
  end

  def variables
    self.text.scan(variable_regex).map { |match| match[0].to_sym }
  end

private

  def set_default_variable_regex
    self.variable_regex = DEFAULT_VARIABLE_REGEX
  end

end