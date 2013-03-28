class AndroidSmsController < ApiController

  # Outbound Sms
  def all
    messages = Android::SmsOutbound.where(:sent => false)
    render :json => messages.to_json
  end

  def update
  end

  # Inbound Sms
  def create
  end

end