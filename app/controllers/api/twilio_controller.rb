class Api::TwilioController < ApiController

  def sms_receive
    underscore
    render_error "Invalid Twilio.sid" if params[:account_sid] != Twilio.account_sid

    sms_trigger_params = params.slice(:body, :from, :to, :from_zip, :from_city, :from_state, :from_country)
    sms_trigger_params[:from] = PhoneHelper.standardize(sms_trigger_params[:from])
    sms_trigger_params[:to] = PhoneHelper.standardize(sms_trigger_params[:to])

    response = Trigger.trigger(nil, "sms:receive", sms_trigger_params)
    render json: response.to_json
  end

  def voice_receive
    underscore

  end

private

  def underscore
    params.keys.each { |orig_key| params[orig_key.underscore] = params.delete(orig_key) }
  end

end