PRODUCTION = true

if Rails.env.production? || PRODUCTION
  account_sid = 'ACc458afd493c7ad55a6da08b2df28f56d'
  auth_token = 'eee531456e7c25281a30b23d07866e89'

  module Twilio
    DEFAULT_PHONE = "+1-207-358-6260"
  end

else
  account_sid = 'ACf98b98936a70e47813f38dcfb1f921d4'
  auth_token = 'aed5fcb8cbfc9026afe45d2a8facbf6b'

  module Twilio
    DEFAULT_PHONE = "+15005550006" 
  end

end

$twilio = Twilio::REST::Client.new account_sid, auth_token


module Twilio
  module REST
    class Message

      def attributes
        h = HashWithIndifferentAccess.new

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
          
          h[attribute] = value
        end
        return h
      end

    end
  end
end

=begin
 
 buy test phone number
 curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACf98b98936a70e47813f38dcfb1f921d4/IncomingPhoneNumbers --data-urlencode "PhoneNumber=+15005550006" -u ACf98b98936a70e47813f38dcfb1f921d4:aed5fcb8cbfc9026afe45d2a8facbf6b 

=end