class Pipe < ActiveRecord::Base
  serialize :variable_regex
  serialize :variables_hash

  attr_accessible :text, :variable_regex, :variables_hash, :key

  def flow(pipelined_hash)
    template = Template.new(self.text, self.variable_regex)
    filled_variables_hash = translate_hash(self.variables_hash, pipelined_hash)
    text = template.fill(filled_variables_hash)

    pipelined_hash[:Templates] ||= {}
    pipelined_hash[:Templates]["_#{key}".to_sym] = text

    return pipelined_hash
  end

  def translate_hash(variables_hash, pipelined_hash)
    variables_hash = variables_hash.deep_copy
    variables_hash.each do |variables_hash_key, variables_hash_value|
      variables_hash[:key] = translate_value!(variables_hash_value, pipelined_hash)
    end
  end

  def translate_value!(variables_hash_value, pipelined_hash)
    cur_hash_value = hash
    key.split(/:/).each do |segment|
      cur_hash_value = cur_hash_value[segment]
    end
  end

end
