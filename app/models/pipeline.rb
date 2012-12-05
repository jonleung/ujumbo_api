class Pipeline < ActiveRecord::Base

  attr_accessible :name, :product_id
  serialize :pipes, Array

  after_initialize :set_defaults
  def set_defaults
    self.pipes ||= []
  end

  def trigger(params)
    obj = {}
    obj[:params] = hash
    obj[:pipes] = self.pipes
    pp obj

    self.pipes.each do |pipe|
      new_params = pipe.flow(params)
    end

  end


end
