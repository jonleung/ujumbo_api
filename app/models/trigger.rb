module Trigger
  include Trigger::Helpers

  serialize :properties
  attr_accessible :product_id, :channel, :properties, :on_class, :on_id

  def trigger(product_id, channel, hash)
    return trigger_via_mysql(product_id, channel, hash)
  end

  def trigger_via_mysql(product_id, channel, hash)
    response_array = []

    triggers = Trigger.where(product_id: product_id, channel: channel)
    triggers.each do |trigger|
      match = true
      trigger.hash.each do |required_key, required_value|
        if hash[:required_key] != required_value
          match = false 
          break
        end
      end
      if match
        klass = trigger.action_klass
        id = trigger.action_id
        object = klass.where(id: id)
        throw "Unable to find #{klass} with id #{id}"

        response_array << object.trigger(hash)
      end
    end

    return response_array
  end

  def trigger_via_redis
    base_redis_key = generate_key({product_id: product_id, channel: channel})
    redis_keys = $redis.keys("#{base_redis_key}*")
    return nil if redis_keys.empty?

    response_array = []

    redis_keys.each do |redis_key|
      begin
        hash = Marshal.load($redis.get(redis_key))
      catch
        throw "#{redis_key} was not set properly and is not a hash"
      end

      klass = hash[:_klass].constantize
      id = hash[:_id]
      hash.rej

      object = klass.find(id)
      return nil if object.nil?
      response_array << response = object.trigger(hash.except(:_id, :_klass))
  end



end