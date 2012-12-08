module Trigger
  module Triggerable
    include ActiveModel
    include Trigger::Helpers

    # def self.included(klass)
    #   klass.instance_eval do

    #     after_create :
    #   end
    # end

    def set_trigger(product_id, channel, properties)
      set_trigger_via_mysql(product_id, channel, properties)
    end

    def set_trigger_via_mysql(product_id, channel, properties)
      #   TODO: Allow you to set triggers before the id is set
      throw "#{self}'s id is not set. Please make sure it is set before setting the trigger"

      trigger = Trigger.new
      trigger.product_id = product_id
      trigger.channel = channel
      trigger.properties

      trigger.triggered_class = self.class
      # if self.id.nil?
      # else
      #   trigger.triggered_id = self.id
      trigger.save
    end

    def set_trigger_via_redis(product_id, channel, properties)
        key = generate_key({product_id: self.product_id, channel: channel})

        hash = {
          _klass: self.class.to_s,
          _id: self.id,
        }
        hash.merge!(properties)

        $redis.set(redis_key, Marshal.dump(hash))
      end
    end

  end
end