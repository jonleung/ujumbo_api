class Trigger
  module Triggerable
    include ActiveModel
    include Trigger::Helpers

    # def self.included(klass)
    #   klass.instance_eval do

    #     after_create :
    #   end
    # end

    def create_trigger(product_id, channel, properties)
      raise "The channel '#{channel}' does not exist" if !channel.in? Trigger.valid_channels
      create_trigger_via_mongo(product_id, channel, properties)
    end

    def create_trigger_via_mongo(product_id, channel, properties)
      #   TODO: Allow you to set triggers before the id is set
      raise "#{self}'s id is not set. Please make sure it is set before setting the trigger" if self.id.nil?

      trigger = Trigger.new
      trigger.product_id = product_id
      trigger.channel = channel
      trigger.properties = properties

      trigger.triggered_class = self.class.to_s
      trigger.triggered_id = self.id
              
      trigger.save

      return trigger.id
    end

  end
end