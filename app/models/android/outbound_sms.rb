module Android
  class OutboundSms
    include Mongoid::Document
    self.mass_assignment_sanitizer = :strict
    include Mongoid::Timestamps
    include Mongoid::Paranoia

    field :status, type: String
    field :to, type: String
    field :body, type: String


  end
end