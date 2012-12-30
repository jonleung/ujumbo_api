class UserPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict

  ACTIONS = {:create => :create}
  PLATFORM_PROPERTIES = [:first_name, :last_name, :email, :phone, :role]

  field :platform_properties_list, type: Array
  field :product_properties_schema, type: Hash
  field :default_properties, type: Hash

  attr_accessible :platform_properties_list, :product_properties_schema, :default_properties

  after_initialize :before_save_hook
  def before_save_hook
    self.product_properties_schema.each { |property_key, klass| self.product_properties_schema[property_key] = klass.to_s }
    # non_platform_keys = self.platform_properties_list - PLATFORM_PROPERTIES
    # raise "These are not platform keys: #{non_platform_keys}" if non_platform_keys.present?
  end

  def flow(pipelined_hash)
    super(pipelined_hash)
    
    case self.action
    when ACTIONS[:create]
      user = create_user(pipelined_hash)
      writeback_to_pipelined_hash("Users", user.all_attributes)
    else
      raise "#{self.action} is invalid for a UserPipe"
    end

    return pipelined_hash
  end

  def create_user(pipelined_hash)
    pipelined_hash.merge!(self.default_properties)
    #TODO need to make sure that those attributes exist or else throw some kind of error?
    platform_properties = pipelined_hash.slice(*self.platform_properties_list)
    user = User.new(platform_properties)
    user.product_properties = pipelined_hash.slice(*(self.product_properties_schema.keys))

    user.save
    return user
  end

end