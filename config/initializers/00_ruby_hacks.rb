class Object

	def deep_copy
		Marshal.load(Marshal.dump(self))
	end

	def in?(array)
		array.include?(self)
	end

end

class String
	def to_bool
		return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
		return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
	end
end

class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end
