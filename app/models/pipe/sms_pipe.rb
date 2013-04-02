class SmsPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def self.properties_list
    [:from_phone, :phone, :body]
  end

  def flow
    notification = SmsNotification.create(combined_properties.slice(*SmsPipe.properties_list))
    writeback_to_pipelined_hash(SmsNotification.to_s, notification.api_response) #TODO, make write_back
  end
end