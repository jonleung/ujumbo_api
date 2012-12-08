module Trigger
  module Triggerable
    include ActiveModel
    include Trigger::Helpers

    def set_trigger(product_id, channel, properties)
      redis_key = generate_key({product_id: self.product_id, channel: channel})

      hash = {
        _klass: self.class.to_s,
        _id: self.id,
      }
      hash.merge!(properties)

      $redis.set(redis_key, Marshal.dump(hash))
    end

  end
end