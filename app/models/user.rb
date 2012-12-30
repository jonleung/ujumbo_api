class User < Thing

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :phone, type: String

  field :role, type: String

  attr_accessible :first_name, :last_name, :phone, :email, :product_properties, :role

  after_save :before_save_hook
  def before_save_hook
    if self.new_record?
    else
      Trigger.trigger(self.product_id, "database:user:save", self.attributes)
    end
    return true
  end

  after_create :after_create_hook
  def after_create_hook
    Trigger.trigger(self.product_id, "database:user:create", self.attributes)
  end

end