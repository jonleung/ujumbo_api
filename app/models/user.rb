class User < ActiveRecord::Base  
  attr_accessible :first_name, :last_name, :phone, :email

  after_save :before_save_hook
  def before_save_hook
    if self.new_record?
    else
      triggers = Trigger.where(on: "database:user:save")
      triggers.each do |trigger|
        trigger.activate(self)
      end
    return true
  end

  after_create :after_create_hook
  def after_create_hook
    triggers = Trigger.trigger("database:user:create", self.attributes)
  end



end