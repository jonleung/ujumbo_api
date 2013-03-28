class Product
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  # include Mongoid::Paranoia

  has_many :pipelines
  has_many :triggers
  has_and_belongs_to_many :users

  field :name, type: String

  attr_accessible :name
  validates_uniqueness_of :name 
  
end
