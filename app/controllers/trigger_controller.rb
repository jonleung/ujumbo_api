class TriggerController < ApplicationController

  def activate
    product_id = params[:product_id]
    render :json => "false" if product_id.nil?
    response = Trigger.trigger(product_id, Trigger::API_CALL, params)
    render :json => response.to_json
  end

end