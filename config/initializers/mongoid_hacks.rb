module Mongoid::Document
	def indifferent_attributes
		HashWithIndifferentAccess.new(self.attributes)
	end
end