ENV["sms_for_real"] ||= "true"

module Twilio

  def self.default_sms_url
    "#{ENV["base_url"]}/twilio/sms"
  end

  def self.default_voice_url
    "#{ENV["base_url"]}/twilio/voice"
  end

  module REST
    class Message

      def attributes
        params = HashWithIndifferentAccess.new

        attrs = %w[sid date_created date_updated date_sent account_sid to from body status direction api_version price]
        attrs.each do |attribute|
          value = self.send(attribute)

          if value.present?
            if attribute.in? %w{date_created date_updated date_sent}
              value = DateTime.parse(value)
            elsif attribute == "status"
              value = value.to_sym
            end
          end
          
          params[attribute] = value
        end
        return params
      end

    end
  end
end

is_production = Rails.env.production? || ENV["sms_for_real"].to_bool

if is_production

  module Twilio
    def self.account_sid
      'ACc458afd493c7ad55a6da08b2df28f56d'
    end

    def self.auth_token
      'eee531456e7c25281a30b23d07866e89'
    end

    def self.default_phone
      "4433933207"
    end
  end

else

  module Twilio
    def self.account_sid
      'ACf98b98936a70e47813f38dcfb1f921d4'
    end

    def self.auth_token
      'aed5fcb8cbfc9026afe45d2a8facbf6b'
    end

    def self.default_phone
      "15005550006"
    end
  end
end

$twilio = Twilio::REST::Client.new Twilio.account_sid, Twilio.auth_token

if is_production
  # Set Appropriate Callback
  params = {
    phone_number: Twilio.default_phone,
  }
  pp "Updating Twilio Callback with params"
  pp params

  incomming_phone_number = $twilio.account.incoming_phone_numbers.create(params)
  params = {
    sms_method: "POST",
    sms_url: Twilio.default_sms_url,
    voice_url: Twilio.default_voice_url
  }
  pp incomming_phone_number.update(params)
end


$twilio.instance_eval do
  def send_sms(params)
    params[:from] ||= Twilio.default_phone
    $twilio.account.sms.messages.create(params)
  end
end