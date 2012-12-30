class Product
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  has_many :pipelines
  has_many :triggers

  field :name, type: String

  attr_accessible :name
  validates_uniqueness_of :name 
  
end
