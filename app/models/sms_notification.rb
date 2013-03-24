class SmsNotification < Notification
  MAX_WAIT = 4

  STATUSES = {
    :queued => :queued,
    :sending => :sending, 
    :sent => :sent,
    :failed => :failed,
  }

  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :user_phone , type: String
  attr_accessor :attributes

  attr_accessible :user_phone

  after_create :before_save_hook
  def before_save_hook
    user = User.find(self.user_id)
    raise "cannot find user with id #{self.user_id}" if user.nil?
    self.user_phone = user.all_attributes[:phone]
    @attributes = self.send_sms
  end

  def send_sms
    #TODO: Check all test cases http://www.twilio.com/docs/api/rest/test-credentials
    sms_params = {
      from: Twilio::DEFAULT_PHONE,
      to: self.user_phone,
      body: self.body
    }

    sms_response = $twilio.account.sms.messages.create(sms_params)
    i = 0
    while sms_response.status != "sent" && sms_response.status != "failed"
      i += 1
      puts "REFRESHING sms status, attempt [#{i} of MAX_WAIT]..."
      sms_response.refresh
      pp sms_response.attributes
      break if i > MAX_WAIT
    end
    
    return sms_response.attributes
  end



end