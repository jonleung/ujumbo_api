class TemplatePipe < Pipe

  ACTIONS = {
    :fill => :fill
  }

  field :template_text, type: String
  field :variable_regex, type: Regexp
  field :variables_hash_schema, type: Hash

  attr_accessible :template_text, :variable_regex, :variables_hash_schema

  def flow(pipelined_hash)
    debugger
    template = Template.new(self.template_text, self.variable_regex)
    filled_variables_hash = TemplatePipe.translate_hash(pipelined_hash, self.variables_hash_schema)
    text = template.fill(filled_variables_hash)

    pipelined_hash[:Templates] ||= {}
    if pipelined_hash[:Templates][self.id].nil?
      pipelined_hash[:Templates][self.id] = text
    end

    return pipelined_hash
  end

  class << self
  
    def translate_hash(pipelined_hash, variables_hash_schema)
      debugger
      variables_hash = variables_hash_schema.deep_copy
      variables_hash_schema.each do |variable, path|
        variables_hash[:key] = translate_value(pipelined_hash, path)
      end
      return variables_hash
    end

  end

end