class Pipeline < ActiveRecord::Base
  include Redis::Objects

  attr_accessible :name, :product_id
  value :pipes

  def call
    puts self.pipes
    return self.pipes
  end


end
