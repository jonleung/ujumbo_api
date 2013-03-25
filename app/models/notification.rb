class Notification
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  TYPES = {
    :sms => :sms,
    :email => :email,
    :push => :push
  }

  field :body, type: String

  attr_accessible :body

end