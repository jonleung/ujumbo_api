module Pipe
  class Base < Ujumbo::UjumboRecord::Base
    
    self.abstract_class = true # THIS LINE MUST BE FIRST!

  end
end