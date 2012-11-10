class TemplafyPipe < Ujumbo::UjumboRecord::Base

  has_one :template

  def input(hash)
    string = template.fill_in(hash)
    output_hash = hash.join({message: string})
  end

end