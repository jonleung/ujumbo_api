class Pipeline
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include Trigger::Triggerable

  belongs_to :product
  has_many :pipes

  field :name, type: String
  field :pipe_order, :type => Array

  attr_accessible :name, :product_id

  def trigger(pipelined_hash)
    pipelined_hash = HashWithIndifferentAccess.new(pipelined_hash)

    keyed_pipes = HashWithIndifferentAccess.new
    self.pipes.each { |pipe| keyed_pipes[pipe.id] = pipe }

    ordered_pipes = []
    self.pipe_order.each { |pipe_id| ordered_pipes << keyed_pipes[pipe_id] }

    ordered_pipes.each do |pipe|
      pipelined_hash = pipe.flow(pipelined_hash)
    end

    return pipelined_hash
  end

end
