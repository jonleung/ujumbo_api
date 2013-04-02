require 'spec_helper'

describe "Pipeline API Spec" do
  it "should create a pipeline" do

    post_params = {
      pipes: [ 
        {
          template_pipe: {
            static_properties: {
              template_text: "Hi :::First Name::: :::Last Name:::, your email is :::Email:::"
            },
            pipelined_properties: {
              "First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
              "Last Name" => "Trigger:Last Name",
              "Email" => "Trigger:Email"
            }
          }
        },
        {
          sms_pipe: {
            static_properties: {
              phone: "1-(610)-761-0083"
            },
            pipelined_properties: {
              body: {
                "Trigger:0:Phone Number"
              }
            }
          }
        }
      ]
    }


  end
end