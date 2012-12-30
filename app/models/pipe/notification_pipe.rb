class NotificationPipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :types, type: Array
  field :user_id, Moped::BSON::ObjectId
  field :variables_hash_schema

  def flow(pipelined_hash)
    super(pipelined_hash)

    notification = nil
    case self.action
    when Notification::TYPES[:sms]
      notification = SmsNotification.new
    when Notification::TYPES[:email]
      notification = EmailNotification.new
    end

    notification.user_id = User.translated_pipelined_references[:user_id]
    

    return pipelined_hash
  end  

end