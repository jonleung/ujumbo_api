class Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :pipeline

  field :previous_pipe_id, type: Integer #-1 represents that it is the one that belongs to a Trigger
  field :action, type: Symbol
  field :pipelined_references, type: Hash

  attr_accessible :previous_pipe_id, :action, :pipelined_references, :pipe_specific
  validates_presence_of :action, :previous_pipe_id

  attr_accessor :pipelined_hash, :_translated_pipelined_references, :pipe_specific

  after_initialize :after_initialize_callback
  def after_initialize_callback
    self.write_attributes(self.pipe_specific)
  end

  def flow(pipelined_hash)
    @pipelined_hash = pipelined_hash
  end

  def translated_pipelined_references
    return @_translated_pipelined_references if @_translated_pipelined_references.present?    

    translated_hash = pipelined_references.deep_copy
    pipelined_references.each do |variable, path|
      translated_hash[variable] = translate_value(path)
    end
    @_translated_pipelined_references = HashWithIndifferentAccess.new(translated_hash)
    return @_translated_pipelined_references
  end

  def translate_value(path)

    cur_hash_value = @pipelined_hash
    path.split(/:/).each do |segment|
      next_hash_value = cur_hash_value[segment]
      if next_hash_value.nil?
        cur_hash_value = Hash[cur_hash_value.map { |k,v| [k.to_s, v] }]
        next_hash_value = cur_hash_value[segment]

        if next_hash_value.nil?
          err = "ERROR on segment \"#{segment}:\" for path: #{path}\n"
          err << "pipelined_hash = #{PP.pp(@pipelined_hash,"")}"
          raise err
        end

      end

      cur_hash_value = next_hash_value
    end

    return cur_hash_value

  end

  def writeback_to_pipelined_hash(key, h)
    @pipelined_hash[key] ||= HashWithIndifferentAccess.new
    base = pipelined_hash[key]
    base[self.id] ||= HashWithIndifferentAccess.new
    instance = base[self.id]
    
    instance.merge!(h)
  end


end