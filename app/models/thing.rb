class Thing
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :product

  field :name, type: String
  field :product_properties, type: Hash

  def all_attributes
    h = HashWithIndifferentAccess.new(self.attributes)
    h.merge!(h[:product_properties])
    h.delete(:product_properties)
    h[:id] = h.delete(:_id)

    return h
  end

  attr_accessible :name, :product_properties

end