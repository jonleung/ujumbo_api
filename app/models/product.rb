class Product < Ujumbo::UjumboRecord::Base
  include Redis::Objects
  
  attr_accessible :name
  has_many :pipelines

  validates :name, :uniqueness => true
  
end
