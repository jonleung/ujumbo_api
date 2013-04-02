class TemplatePipe < Pipe
  
  field :template_text, type: String
  field :variable_regex, type: Regexp

  attr_accessible :template_text, :variable_regex

  def flow
  	debugger
    template = Template.new(combined_properties[:template_text], self.variable_regex)

    text = template.fill(combined_properties[:template_text])
    h = {text: text}

    writeback_to_pipelined_hash("Templates", h)
  end

end