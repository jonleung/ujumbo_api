module Trigger
  include Trigger::Helpers

  def trigger(product_id, channel, hash)
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

    return response_array
  end

end