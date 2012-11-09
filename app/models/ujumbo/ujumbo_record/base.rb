module Ujumbo
  module UjumboRecord
    class Base < ActiveRecord::Base

      self.abtract_class = true # THIS LINE MUST BE FIRST!

    end
  end
end