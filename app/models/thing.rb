class Thing
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :product

  field :name, type: String
  field :product_properties, type: Hash

  attr_accessible :name, :product_properties

end