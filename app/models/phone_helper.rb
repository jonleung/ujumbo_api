module PhoneHelper

  def self.standardize(string)
    phone = string.gsub(/[^0-9]/, '')
    phone = "1"+phone if phone.size == 10
    return phone
  end

end