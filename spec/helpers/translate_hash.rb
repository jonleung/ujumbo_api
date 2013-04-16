require 'active_support/core_ext/hash/indifferent_access'

sms_trigger_hash = {
  :Trigger => {
    :To => "Ujumbo phone number",
    "Message" => "This is the message to Ujujmbo"  
  },
  "Some Other Shit" => {
    shit: "the shit"
  }
}

email_trigger_hash = {
  "Trigger" => {
    :from => "naruto137@gmail.com",
    "google_doc_id" => "1038rj03jmwei301m2foiwqmd",
    :worksheet_name => "Email",
    "text" => "Yes I would love a cupcake!"
  },
  :SomeOtherShit => {
    "shit" => "the shit"
  }

}


simple_hash = {
  :previous_pipe_id => "first_pipe",
  :static_properties => {
      :from_phone => "1111111111"
  },
  :pipelined_properties => {
    :phone => "Trigger:To",
    :body => "Trigger:Message"
  }
}

complex_hash = { :previous_pipe_id => "first_pipe",
  :action => :update_row,
  :static_properties => {
    :find_by_params => {
      :google_doc_id => "128017w3aen0e0fae",
      :worksheet_name => "Email"  
    }
  },
  :pipelined_properties => {
    :find_by_params => {
      "To" => "Trigger:from",
    },
    update_to_params: {
      "Response" => "Trigger:text"
    }
  }
}


class Pipe

  def initialize(pipelined_hash)
    @pipelined_hash = pipelined_hash
  end

  attr_accessor :pipelined_hash, :static_properties

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

pipe = Pipe.new(sms_trigger_hash)
pipe.get_attr(:To)