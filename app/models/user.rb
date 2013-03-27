class User
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :google_uid, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :photo, type: String

  field :verified_email, type: Boolean
  field :google_plus, type: String
  field :gender, type: String
  field :locale, type: String

  embeds_one :google_credential
  belongs_to :product

end