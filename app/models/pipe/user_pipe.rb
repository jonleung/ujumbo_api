class UserPipe < ActiveRecord::Base

  ACTIONS = {:create => "create"}
  PLATFORM_PROPERTIES = [:first_name, :last_name, :email, :phone]

  serialize :platform_properties_keys, :product_properties_type_hash
  attr_accessible :action, :platform_properties_keys, :product_properties_type_hash, :type, :key

  after_initialize :after_initialize_hook
  def after_initialize_hook
    non_platform_keys = self.platform_properties_keys - PLATFORM_PROPERTIES
    raise "These are not platform keys: #{non_platform_keys}" if non_platform_keys.present?
  end

  def flow(pipelined_hash)
    
    key = self.key.to_sym
    
    case self.action
    when ACTIONS[:create]
      user = create_user(pipelined_hash)

      pipelined_hash[:Users] ||= {}
      if pipelined_hash[:Users][key].nil?
         pipelined_hash[:Users][key] = user.attributes
      else
        raise "There is another User keyed into #{key}"
      end
    else
      raise "#{self.action} is invalid for a UserPipe"
    end

    return pipelined_hash
  end

  def create_user(pipelined_hash)
    platform_properties = pipelined_hash.slice(*self.platform_properties_keys)
    user = User.new(platform_properties_keys)
    user.product_properties = pipelined_hash.slice(*self.product_properties_type_hash.keys)

    user.save
    return user
  end

end