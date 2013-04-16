class EmailNotification
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :from, type: String
  field :to, type: Array
  field :cc, type: Array
  field :bcc, type: Array
  field :subject, type: String
  field :text_body, type: String
  field :html_body, type: String
  field :google_doc_id, type: String

  attr_accessible :to, :cc, :bcc, :subject, :from, :text_body, :html_body, :google_doc_id

  after_create :after_create_hook

  def after_create_hook
  	self.send_mail
  end

  def send_mail
    send_with_ujumbo_gmail_action_mailer
  end

  def send_with_ujumbo_gmail_action_mailer
    params = self.indifferent_attributes.except("_id", "updated_at", "created_at")
    params.merge!(reply_to: "reply_to_#{self.google_doc_id}@modmail.cc")
    response = UserMailer.send_mail(params).deliver
  end

end