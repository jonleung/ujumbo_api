require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
			client = ApiClient.new

			product = Product.find_or_create_by(name: "PennKey")
			filename = "Pipelining Extravaganza 11!"
			google_doc = GoogleDoc.where(filename: filename).first
			if google_doc.nil?
				google_doc_params = {
				  username: "hello@ujumbo.com",
				  password: "movefastandbreakthings",
				  filename: filename,
				  create_new: "true",
				  product_id: product.id,
				  schema: {
				  	"First Name" => :first_name,
				  	"Last Name" => :last_name,
				  	"Phone Number" => :phone,
				  	"Email" => :email,
				  	"Date" => :date,
				  	"Address" => :address,
				  	"Message" => :text
				  }
				}

				response = client.post("/google_docs/spreadsheet/create/", google_doc_params)
				google_doc = GoogleDoc.find(response["_id"])
			end

		    pipeline = product.pipelines.new
		    pipeline.name = "name#{Pipeline.count}"
		    pipeline.save.should == true

		    pipeline.create_trigger(product.id, "google_spreadsheet:row:create", {google_doc_id: google_doc.id} )

		    # TEMPLATE
		    template_pipe = TemplatePipe.new({
		    				  :previous_pipe_id => -1,
		                      :action => :fill,
		                      :pipe_specific => {
		                      	:template_text => "Hi :::First Name::: :::Last Name:::, your email is :::Email:::" #filled 
		                      },
		                      :pipelined_references => {
		                      	"First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
		                      	"Last Name" => "Trigger:Last Name",
		                      	"Email" => "Trigger:Email"
		                      }
		                    }) 
		    template_pipe.pipeline = pipeline
		    template_pipe.save.should == true 

		    # NOTIFICATION
		    notification_pipe = NotificationPipe.new({
		    			:previous_pipe_id => template_pipe.id,
		                :action => :create,
		                :pipe_specific => {
		                	:type => :sms,	
		                },
		                :pipelined_references => {
		                  :phone => "Trigger:Phone Number",
		                  :body => "Templates:#{template_pipe.id}:body" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
		                }    
		               })
		    notification_pipe.pipeline = pipeline
		    notification_pipe.save.should == true


		    pipeline.save.should == true
	end
end
