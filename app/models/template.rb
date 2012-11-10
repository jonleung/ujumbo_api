class Template < Ujumbo::UjumboRecord::Base
  
  attr_accessible :text
  list :variable_keys

  def fill_in(variables)
    #filles in text with variables and
    # outputs a string
  end

end
