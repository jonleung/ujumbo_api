module Trigger
  module Helpers

    def generate_key(hash)
      throw "Unable to generate key without both product_id and channel" if hash[:product_id].nil? || hash[:channel].nil?
      product_id = hash[:product_id]
      channel = hash[:channel]

      key = "product#{product_id}:#{channel}"
    end

  end
end