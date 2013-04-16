class Api::SendgridController < ApiController

  def callback
    $redis.set("last_email", Marshal.dump(params))
    debugger
    email_trigger_params = edit_params(params)
    response = Trigger.trigger(nil, "email:receive", email_trigger_params)
    render json: email_trigger_params.to_json
  end

private

  def edit_params(params)
    new_params = HashWithIndifferentAccess.new(params)
    debugger
    new_params.merge!(params.slice(:text, :html))
    new_params[:from] = params[:from][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    new_params[:google_doc_id] = /#{EmailNotification.default_heading}(.*?)@/.match(params[:to])[1]
  end

end