module Ujumbo
  module UjumboRecord
    class Base < ActiveRecord::Base
      
      # self.abstract_class = true # THIS LINE MUST BE FIRST!

      # def self.find_or_create(attributes)
        
      #   if obj = self.where(attributes).first
      #     obj.instance_eval do
      #       def status
      #         :existing
      #       end
      #     end

      #     return obj
      #   else
      #     self.create(attributes) do
      #       def status
      #         :new
      #       end
      #     end
      #   end

      # end

    end
  end
end