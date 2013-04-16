class Trigger
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include Trigger::Helpers

  belongs_to :product

  def self.valid_channels 
    %w{
      database:user:create
      database:user:update
      database:user:destroy

      api_call

      google_docs:spreadsheet:row:create
      google_docs:spreadsheet:row:update
      google_docs:spreadsheet:row:destroy

      sms:receive
      voice:receive
    }
  end

  field :channel, type: String
  field :properties, type: Hash

  field :triggered_class, type: String
  field :triggered_id, type: Moped::BSON::ObjectId

  attr_accessible :channel, :properties, :triggered_class, :triggered_id

  class << self

    def trigger(product_id, channel, triggering_properties)
      raise "The channel '#{channel}' does not exist" if !channel.in? Trigger.valid_channels 
      triggering_properties = HashWithIndifferentAccess.new(triggering_properties)
      return trigger_via_mongo(product_id, channel, triggering_properties)
    end

    def trigger_via_mongo(product_id, channel, triggering_properties)
      response_array = []
      
      if product_id.nil?
        triggers = Trigger.where(channel: channel).entries
      else
        triggers = Trigger.where(product_id: product_id, channel: channel).order_by(date_created: "dsc")
      end

      triggers.each do |trigger|
        match = true
        trigger.properties.each do |required_key, required_value|
          if triggering_properties[required_key] != required_value
            match = false
            break
          end
        end
        
        if match
          klass = trigger.triggered_class.constantize
          id = trigger.triggered_id
          object = klass.find(id)
          triggering_properties = HashWithIndifferentAccess.new({:Trigger => triggering_properties})
          response_array << object.trigger(triggering_properties)
        end
      end

      return response_array
    end


  end
end