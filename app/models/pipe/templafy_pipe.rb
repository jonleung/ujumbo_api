class TemplafyPipe < Ujumbo::UjumboRecord::Base

  has_one :template

  def flow(hash)
    string = template.fill(hash)
    output_hash = hash.join({Template: string})
  end

end