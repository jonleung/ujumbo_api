class TriggerController < ApplicationController

  def create
  end

  def activate
    trigger = Trigger.find(params[:id])
    params.merge!(:source => Trigger::API_CALL)
    response = trigger.activate(params)
    render :json => response.to_json
  end

end