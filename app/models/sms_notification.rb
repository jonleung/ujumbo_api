class SmsNotification < Notification
  MAX_WAIT = 4

  STATUSES = {
    :queued => :queued,
    :sending => :sending, 
    :sent => :sent,
    :failed => :failed,
  }

  field :phone , type: String
  field :properties, type: Hash

  attr_accessible :phone

  after_create :after_create_hook
  def after_create_hook
    self.properties = self.send_sms
  end

  def send_sms
    debugger
    #TODO: Check all test cases http://www.twilio.com/docs/api/rest/test-credentials
    sms_params = {
      from: Twilio::DEFAULT_PHONE,
      to: self.phone,
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