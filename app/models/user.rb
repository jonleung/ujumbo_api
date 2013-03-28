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

  has_and_belongs_to_many :products
  validates_uniqueness_of :google_uid, allow_nil: true

  def self.from_omniauth(params)
    user_params = params[:user_params]
    credential_params = params[:credential_params]

    if user = User.where(google_uid: user_params[:google_uid]).first
      user.google_credential = GoogleCredential.new(credential_params)
      user.update(user_params.except(:google_uid))
    else
      user = User.create(user_params)
      user.google_credential = GoogleCredential.new(credential_params)
    end
    raise "Unable to find or create user" if user.nil?
    return user
  end

end