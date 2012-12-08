class Pipeline < ActiveRecord::Base
  include Trigger::Triggerable

  attr_accessible :name, :product_id
  serialize :pipes, Array

  after_initialize :set_defaults
  def set_defaults
    self.pipes ||= []
  end

  def trigger(pipelined_hash)
    puts "TRIGGERED"
    obj = {}
    obj[:params] = pipelined_hash
    obj[:pipes] = self.pipes
    pp obj

    # new_params = params
    # self.pipes.each do |pipe|
    #   new_params = pipe.flow(new_params)
    # end

  end


end
