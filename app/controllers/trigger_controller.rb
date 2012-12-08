class TriggerController < ApplicationController

  def activate
    debugger
    trigger = Trigger.find(params[:id])
    params.merge!(:source => Trigger::API_CALL)
    response = trigger.activate(params)
    render :json => response.to_json
  end

end