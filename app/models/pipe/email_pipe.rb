class EmailPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def flow
  	attrs = HashWithIndifferentAccess.new()

  	attrs[:from] = translated_pipelined_references[:from]
  	attrs[:subject] = translated_pipelined_references[:subject]
  	
  	[:to, :cc, :bcc].each do |field|
  		if (value = translated_pipelined_references[field]).present?
	  		emails = value.split(',')
	  		attrs[field] = emails
	  	end
  	end

  	attrs[:text_body] = attrs[:html_body] = translated_pipelined_references[:body]

  	email = EmailNotification.create(attrs)

  	writeback_to_pipelined_hash(EmailNotification.to_s, email.attributes)
  end

end