class Trigger < Ujumbo::UjumboRecord::Base
  after_initialize :set_defaults
  def set_defaults
    self.action ||= {}
  end

  before_save :clean_hash
  def clean_hash
    self.action[:klass] = self.action[:klass].to_s
  end

  API_CALL = :api_call

  def activate(params)
    if params[:source] == API_CALL && self.on == API_CALL
      #pass
    else
      raise "Trigger source #{params[:source]} does not exist."
      return nil
    end

    klass = self.action[:klass].constantize
    id = self.action[:id]

    object = klass.find(id)

    if object == nil
      return nil 
      
    else
      return object.trigger(params)
    end
  end

end
