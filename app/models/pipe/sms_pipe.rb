class SmsPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def flow
    notification = SmsNotification.create(translated_pipelined_references)
    writeback_to_pipelined_hash(SmsNotification.to_s, notification.attributes) #TODO, make write_back
  end
end