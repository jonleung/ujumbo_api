class Api::SendgridController < ApiController

  def callback 
    # $redis.set("last_email", Marshal.dump(params))
    params = Marshal.load($redis.get("last_email")); 
    email_trigger_params = edit_params(params)
    debugger
    response = Trigger.trigger(nil, "email:receive", email_trigger_params)
    render json: email_trigger_params.to_json
  end

private

  def edit_params(params)
    new_params = HashWithIndifferentAccess.new
    new_params.merge!(params.slice(:text, :html))
    new_params[:from] = params[:from][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    new_params[:to] = params[:to][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    new_params[:google_doc_id] = /#{EmailNotification.default_heading}(.*?)@/.match(new_params[:to])[1]
    return new_params
  end

end