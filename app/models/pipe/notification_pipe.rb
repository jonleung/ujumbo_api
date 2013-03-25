class NotificationPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  ACTIONS = {
    :create => :create
  }

  field :type, type: Symbol

  attr_accessible :type

  def flow(pipelined_hash)
    super(pipelined_hash)

    notification = nil

    case self.action

    # CREATE
    when NotificationPipe::ACTIONS[:create]
      case self.type
      when Notification::TYPES[:sms]
        notification = SmsNotification.new
      when Notification::TYPES[:email]
        notification = EmailNotification.new
      end
      notification.user_id = translated_pipelined_references[:user_id] #TODO, make it so that it is not :_id
      notification.body = translated_pipelined_references[:body]
      notification.save

      debugger
                                                                          #TODO, standardize other notifications with attributes as the param as well or make it specific code
      writeback_to_pipelined_hash(notification.class.to_s, notification.attributes) #TODO, make write_back
    end
      
    return pipelined_hash
  end  

end