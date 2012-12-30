class Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  belongs_to :pipeline

  field :action, type: Symbol
  attr_accessible :action
  validates_presence_of :action
    
  def self.translate_value(pipelined_hash, path)
    cur_hash_value = pipelined_hash
    path.split(/:/).each do |segment|
      next_hash_value = cur_hash_value[segment]
      if next_hash_value.nil?
        next_hash_value = Hash[cur_hash_value.map { |k,v| [k.to_s, v] }]

        if next_hash_value.nil?
          puts "ERROR: Unable to translate hash"
          puts "path: #{path}"
          puts "pipelined_hash = "
          pp pipelined_hash
          throw "Unable to translate hash"
        end
        
      end

      cur_hash_value = next_hash_value
    end
    return cur_hash_value
  end

end