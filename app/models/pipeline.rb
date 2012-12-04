class Pipeline < ActiveRecord::Base
  include Redis::Objects

  attr_accessible :name, :product_id
  list :pipes, :marshal => true

  def trigger(params)
    obj = {}
    obj[:params] = hash
    obj[:pipes] = self.pipes
    pp obj


    # self.pipes.each do |pipe|
    #   pipe.call
    # end

    return obj
  end


end
