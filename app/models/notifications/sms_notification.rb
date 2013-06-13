class SmsNotification
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  MAX_WAIT = 4

  STATUSES = {
    :queued => :queued,
    :sending => :sending, 
    :sent => :sent,
    :failed => :failed,
  }

  field :from_phone, type: String
  field :phone, type: String
  field :body, type: String
  field :api_response, type: Hash

  attr_accessible :from_phone, :phone, :body

  after_create :after_create_hook
  def after_create_hook
    self.api_response = self.send_sms
    self.from_phone ||= Twilio.default_phone
  end

  def send_sms
    #TODO: Check all test cases http://www.twilio.com/docs/api/rest/test-credentials
    sms_params = {
      from: self.from_phone,
      to: self.phone,
      body: self.body
    }

    sms_response = $twilio.account.sms.messages.create(sms_params)
    # i = 0
    # while sms_response.status != "sent" && sms_response.status != "failed"
    #   i += 1
    #   puts "REFRESHING sms status, attempt [#{i} of MAX_WAIT]..."
    #   sms_response.refresh
    #   pp sms_response.attributes
    #   break if i > MAX_WAIT
    # end
    
    return sms_response.attributes
  end



end