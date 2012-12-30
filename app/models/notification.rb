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

  belongs_to :user
  field :body, type: String

  attr_accessible :from_user, :to_user, :body

end