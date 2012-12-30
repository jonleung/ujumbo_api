class SmsNotification < Notification
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :user_phone , type: String

  attr_accessible :user_phone

  after_create :before_save_hook
  def before_save_hook
    self.user_phone = self.user.phone
    return self.send   
  end

  def send
    sms_params = {
      from: Twilio::DEFAULT_PHONE,
      to: self.user_phone,
      body: self.body
    }
    debugger
    return $twilio.account.sms.message.create(sms_params)
  end


end