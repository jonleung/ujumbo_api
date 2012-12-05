class Pipe < Ujumbo::UjumboRecord::Base
  attr_accessible :type

  
  def flow(params)
    
  end

  def active_crud
    
  end

  def templafy(hash)
    string = template.fill(hash)
    output_hash = hash.join({Template: string})
  end

end
