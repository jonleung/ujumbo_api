class Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :pipeline

  field :previous_pipe_id, type: String #(nil for the first one)
  field :action, type: Symbol
  field :static_properties, type: Hash
  field :pipelined_properties, type: Hash

  attr_accessible :previous_pipe_id, :action, :pipelined_properties, :static_properties
  validates_presence_of :previous_pipe_id

  attr_accessor :pipelined_hash, :_translated_pipelined_properties

  after_initialize :after_initialize_callback
  def after_initialize_callback
    self.static_properties.each do |key, value|
      self.write_attribute(key, value) #TODO, should I really be doing this?
    end
  end

  def static_properties
    HashWithIndifferentAccess.new(self[:static_properties])
  end

  def receive_pipelined_hash(pipelined_hash)
    @pipelined_hash = pipelined_hash
  end

  def get_pipelined_hash
    @pipelined_hash
  end

  def flow(pipelined_hash)
    @pipelined_hash = pipelined_hash
  end

  def get_attr(key)
    if (value = static_properties[key])
      return value
    else
      return translated_pipelined_properties[key]
    end
  end

  def combined_properties
    translated_pipelined_properties.merge(static_properties)
  end

  def translated_pipelined_properties
    return @_translated_pipelined_properties if @_translated_pipelined_properties.present?    

    translated_hash = pipelined_properties.deep_copy
    pipelined_properties.each do |variable, path|
      translated_hash[variable] = translate_value(path)
    end
    @_translated_pipelined_properties = HashWithIndifferentAccess.new(translated_hash)
    return @_translated_pipelined_properties
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