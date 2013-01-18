class Trigger
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include Trigger::Helpers

  belongs_to :product

  CHANNELS = { #TODO Make sure that everything goes through here
    database: {
      user: {
        create: "database:user:create",
        update: "database:user:update",
        destroy: "database:user:destroy"
      }
    },
    api_call: "api_call",
    dropbox: {
      file: {
        added: {
          type: "csv"
        }
      }
    }

  }

  field :channel, type: String
  field :properties, type: Hash

  field :triggered_class, type: String
  field :triggered_id, type: Moped::BSON::ObjectId

  attr_accessible :channel, :properties, :triggered_class, :triggered_id

  class << self

    def trigger(product_id, channel, triggering_properties)
      return trigger_via_mongo(product_id, channel, triggering_properties)
    end

    def trigger_via_mongo(product_id, channel, triggering_properties)
      response_array = []

      triggers = Trigger.where(product_id: product_id, channel: channel)
      
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
          response_array << object.trigger(triggering_properties)
        end
      end

      return response_array
    end


  end
end