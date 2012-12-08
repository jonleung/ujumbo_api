class Product < ActiveRecord::Base
  
  attr_accessible :name
  has_many :pipelines
  has_many :triggers

  validates :name, :uniqueness => true
  
end
