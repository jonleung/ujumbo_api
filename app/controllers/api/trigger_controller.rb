class Api::TriggerController < ApiController

  def activate
    product_id = params[:product_id]
    render :json => "false" if product_id.nil?
    response = Trigger.trigger(product_id, "api_call", params)
    render :json => response.to_json
  end

end