class Pipeline < ActiveRecord::Base
  belongs_to :product
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

    self.pipes.each do |pipe|
      pipelined_hash = pipe.flow(pipelined_hash)
    end

  end


end
