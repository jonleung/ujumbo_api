class EmailPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def flow
  	attrs = HashWithIndifferentAccess.new()

  	attrs[:from] = get_attr(:from)
  	attrs[:subject] = get_attr(:subject)
    attrs[:google_doc_id] = get_attr(:google_doc_id)
  	
  	[:to, :cc, :bcc].each do |field|
  		if ( value = get_attr(field) ).present?
	  		emails = value.split(',')
	  		attrs[field] = emails
	  	end
  	end

  	attrs[:text_body] = attrs[:html_body] = get_attr(:body)

  	email = EmailNotification.create(attrs)

  	writeback_to_pipelined_hash(EmailNotification.to_s, email.attributes)
  end

end