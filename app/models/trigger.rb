class Trigger < Ujumbo::UjumboRecord::Base
  include Redis::Value
  include Redis::Objects

  value :on, :marshal => true
  value :action, :marshal => true

  API_CALL = :api_call

  def activate(params)
    if params[:source] == API_CALL && self.on == API_CALL
      #pass
    else
      raise "Trigger source #{params[:source]} does not exist."
      return nil
    end

    action = self.action.get
    debugger
    klass = action[:klass]
    id = action[:id]

    object = klass.find(id)
    if object == nil
      return nil 
    else
      return object.trigger(params)
    end
  end

end
