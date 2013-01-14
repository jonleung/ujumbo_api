require 'spec_helper'

describe "send sms" do
  message = Android::OutboundSms.new({to: "+16107610083", body: "msg1: hello bob"})
  message.save

  message = Android::OutboundSms.new({to: "+16107610083", body: "msg2: what is going on?"})
  message.save

  message = Android::OutboundSms.new({to: "+16107610083", body: "msg3: fuck yes!"})
  message.save

  client = ApiClient.new
  response = client.post("/android/sms/}", {product_id: product.id, role: "student"}.merge(student_hash), debug: true)


end