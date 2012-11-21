module Ujumbo
  module UjumboRecord
    class Base < ActiveRecord::Base
      
      self.abstract_class = true # THIS LINE MUST BE FIRST!

    end
  end
end