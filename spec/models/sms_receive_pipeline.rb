require 'spec_helper'

describe "Receiving an SMS" do

  it "should be triggered" do
    user = User.where(email: "hello@ujumbo.com").first
    raise "Cannot find hello@ujumbo.com" if user.nil?

    product = Product.find_or_create_by(name: "PennKey")
    user.products << product
    user.save

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save.should == true

    Trigger.delete_all
    pipeline.create_trigger(product.id, "sms:receive", {to: PhoneHelper.standardize("4433933207")} ) #TODO should the channel be "receive:sms:4433933207"

    # TEMPLATE
    template_pipe = TemplatePipe.new({
                      :previous_pipe_id => "first_pipe",
                      :static_properties => {
                        :template_text => "Hello! :::phone::: just ordered :::body::: from their :::city:::, :::state::: phone." #filled 
                      },
                      :pipelined_properties => {
                        "phone" => "Trigger:from", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
                        "body" => "Trigger:body",
                        "city" => "Trigger:from_city",
                        "state" => "Trigger:from_state"
                      }
                    }) 
    template_pipe.pipeline = pipeline
    template_pipe.save.should == true 

    # NOTIFICATION
    sms_pipe = SmsPipe.new({
                :previous_pipe_id => template_pipe.id,
                :static_properties => {
                  :phone => "6107610083"
                },
                :pipelined_properties => {
                  :body => "Templates:#{template_pipe.id}:text" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
                }    
               })
    sms_pipe.pipeline = pipeline
    sms_pipe.save.should == true

    email_pipe = EmailPipe.new({
          :previous_pipe_id => sms_pipe.id,
          :static_properties => {
            :from => "hello@ujumbo.com",
            :to => "naruto137@gmail.com",
          },
          :pipelined_properties => {
            :body => "Templates:#{template_pipe.id}:text",
            :subject => "Trigger:body"
          }
      })
    email_pipe.pipeline = pipeline
    email_pipe.save.should == true

    pipeline.save.should == true

  end

end