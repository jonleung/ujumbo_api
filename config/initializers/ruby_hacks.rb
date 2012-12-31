class Object

  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

  def in?(array)
    array.include?(self)
  end

end