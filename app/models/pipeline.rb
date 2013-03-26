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
    pipes = self.pipes
    pipes_mapping = HashWithIndifferentAccess.new #maps from pipe_id => pipe
    prev_pipes_mapping = HashWithIndifferentAccess.new #maps previous_pipe_id => pipe that contains the preivous_pipe_id
    pipes.each do |pipe|
      pipes_mapping[pipe.id] = pipe
      # prev_pipes_mapping[pipe.previous_pipe_id] ||= []
      # prev_pipes_mapping[pipe.previous_pipe_id] << pipe
      prev_pipes_mapping[pipe.previous_pipe_id] = pipe
    end

    curr_pipe = prev_pipes_mapping["first_pipe"]
    ordered_pipes = []
    ordered_pipes << curr_pipe
    
    while true
      next_pipe = prev_pipes_mapping[curr_pipe.id.to_s]
      break if next_pipe == nil
      ordered_pipes << next_pipe
      curr_pipe = next_pipe
    end

    ordered_pipes.each do |pipe|
      pipe.receive_pipelined_hash(pipelined_hash)
      pipe.flow
      pipelined_hash = pipe.get_pipelined_hash

    end

    return pipelined_hash
  end

end
