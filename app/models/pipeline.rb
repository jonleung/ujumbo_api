class Pipeline < ActiveRecord::Base
  include Redis::Objects

  attr_accessible :name, :product_id
  list :pipes, :marshal => true

  def call(hash)
    obj = {}
    obj[:params] = hash
    obj[:pipes] = self.pipes
    pp obj
    return obj
  end


end
