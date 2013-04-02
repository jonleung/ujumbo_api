require 'spec_helper'

describe "demo-ing the project" do
  it "should work" do
    user = User.where(email: "hello@ujumbo.com").first
    raise "Cannot find hello@ujumbo.com" if user.nil?

    product = Product.find_or_create_by(name: "ProjectDemo")
    user.products << product
    user.save

    client = ApiClient.new

    filename = "demo_1"
    google_doc_params = {
      user_id: user.id,
      filename: filename,
      create_new: "true",
      product_id: product.id,
      schema: {
        "Phone Number" => :phone,
        "Name" => :first_name,
        "Email" => :email,
        "Embedded Form" => :text,
        "Send Embedded Form" => :triggering_column,
        "Num Times Viewed" => :integer,
        "Their Email Response" => :triggering_column,
        "Form Response" => :text,
      }
    }

    google_doc = GoogleDoc.find_or_create_by(google_doc_params)

    # now that the google doc is created, we want to receive an SMS, and print the from_phone_# and 
    # message_body into the google 

# FIRST PIPELINE
    email_with_form_pipelined = product.pipelines.new
    email_with_form_pipelined.name = "name#{Pipeline.count}"
    email_with_form_pipelined.save.should == true

    first_sms_pipeline.create_trigger(product.id, "sms:receive" ,  {to: PhoneHelper.standardize("4433933207")} )

    # on sms receive, create a row
      gdoc_create_row_pipe = GoogleDocPipe.new({
        :previous_pipe_id => "first_pipe",
        :action => :create_row,
        :static_properties => {
          :google_doc_id => google_doc.id
        },
        :pipelined_properties => {
          "Phone Number" => "Trigger:from",
          "Name" => "Trigger:body"
        }
      })

      gdoc_create_row_pipe.pipeline = first_sms_pipeline
      gdoc_create_row_pipe.save.should == true 

      # Then respond to the message 
      template_pipe = TemplatePipe.new({
                        :previous_pipe_id => gdoc_create_row_pipe.id,
                        :static_properties => {
                          :template_text => "Hello :::name:::! What is your email address?" #filled 
                        },
                        :pipelined_properties => {
                          "name" => "Trigger:body"
                      }
                      }) 
      template_pipe.pipeline = first_sms_pipeline
      template_pipe.save.should == true 

      # NOTIFICATION
      sms_pipe = SmsPipe.new({
                  :previous_pipe_id => template_pipe.id,
                  :static_properties => {
                    :from_phone => "2073586260",
                  },
                  :pipelined_properties => {
                    :phone => "Trigger:from",
                    :body => "Templates:#{template_pipe.id}:text" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
                  }    
                 })
      sms_pipe.pipeline = first_sms_pipeline
      sms_pipe.save.should == true
      first_sms_pipeline.save.should == true

# SECOND PIPELINE
    second_sms_pipeline = product.pipelines.new
    second_sms_pipeline.name = "name#{Pipeline.count}"
    second_sms_pipeline.save.should == true

    second_sms_pipeline.create_trigger(product.id, "sms:receive" ,  {to: PhoneHelper.standardize("2073586260")} )

    # on sms receive, update the row with the person's email that they gave
      gdoc_update_row_pipe = GoogleDocPipe.new({
        :previous_pipe_id => "first_pipe",
        :action => :update_row,
        :static_properties => {
          :google_doc_id => google_doc.id
        },
        :pipelined_properties => {
          "update_to_Email" => "Trigger:body",
          "find_by_Phone Number" => "Trigger:from"
        }
      })

      gdoc_update_row_pipe.pipeline = second_sms_pipeline
      gdoc_update_row_pipe.save.should == true 

      # Then respond to the message 
      # NOTIFICATION
      pineapple_sms_pipe = SmsPipe.new({
                  :previous_pipe_id => gdoc_update_row_pipe.id,
                  :static_properties => {
                    :from_phone => "4158586914",
                    :body => "How many pineapple juices does it take to reach the Ballmer peak?"
                  },
                  :pipelined_properties => {
                    :phone => "Trigger:from",
                   }    
                 })
      pineapple_sms_pipe.pipeline = second_sms_pipeline
      pineapple_sms_pipe.save.should == true

    second_sms_pipeline.save.should == true

# THIRD PIPELINE
    third_sms_pipeline = product.pipelines.new
    third_sms_pipeline.name = "name#{Pipeline.count}"
    third_sms_pipeline.save.should == true

    third_sms_pipeline.create_trigger(product.id, "sms:receive" ,  {to: PhoneHelper.standardize("2073586260")} )

    # on sms receive, update the row with the person's email that they gave
      gdoc_update_row_pipe = GoogleDocPipe.new({
        :previous_pipe_id => "first_pipe",
        :action => :update_row,
        :static_properties => {
          :google_doc_id => google_doc.id
        },
        :pipelined_properties => {
          "update_to_Email" => "Trigger:body",
          "find_by_Phone Number" => "Trigger:from"
        }
      })

      gdoc_update_row_pipe.pipeline = second_sms_pipeline
      gdoc_update_row_pipe.save.should == true 

      # Then respond to the message 
      # NOTIFICATION
      pineapple_sms_pipe = SmsPipe.new({
                  :previous_pipe_id => gdoc_update_row_pipe.id,
                  :static_properties => {
                    :from_phone => "4158586914",
                    :body => "How many pineapple juices does it take to reach the Ballmer peak?"
                  },
                  :pipelined_properties => {
                    :phone => "Trigger:from",
                   }    
                 })
      pineapple_sms_pipe.pipeline = second_sms_pipeline
      pineapple_sms_pipe.save.should == true

    second_sms_pipeline.save.should == true
  end
end
