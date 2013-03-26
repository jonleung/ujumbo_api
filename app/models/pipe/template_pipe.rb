class TemplatePipe < Pipe

  ACTIONS = {
    :fill => :fill
  }

  field :template_text, type: String
  field :variable_regex, type: Regexp

  attr_accessible :template_text, :variable_regex

  def flow
    template = Template.new(self.template_text, self.variable_regex)

    text = template.fill(translated_pipelined_references)
    h = {text: text}

    writeback_to_pipelined_hash("Templates", h)
  end

end