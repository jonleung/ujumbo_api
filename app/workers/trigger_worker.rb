class TriggerWorker
  @queue = :triggers_queue

  def self.perform(product_id, channel, properties)
    debugger
    Trigger.trigger_via_mongo(product_id, channel, properties)
  end

end