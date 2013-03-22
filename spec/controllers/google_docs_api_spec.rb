require 'spec_helper'

describe "Google Docs create" do
	it "should create a new document" do

		#product = Product.find("514a64ae1f127d9abc000001")
		client = ApiClient.new
	    google_doc_params = {
	      username: "hello@ujumbo.com",
	      password: "movefastandbreakthings",
	      filename: "test_sheet",
	      create_new: "true",
	      #product_id: product.id,
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
	    debugger
=begin
	    pipeline = product.pipelines.new
	    pipeline.name = "name#{Pipeline.count}"
	    pipeline.save.should == true
	    pipe_order = []



schema: {	"First Name" => :first_name,
			"Last Name" => :last_name,
			"Phone Number" => :phone,
			"Email" => :email,
			"Date" => :date,
			"Address" => :address,
			"Message" => :text
		},

	
		{

			PipelinedHash {
				Trigger: {
					_channel: "google_calendar:event:start",
					"Name" => {
									type: :text,
									value: "Code @ Night"
					},
					"Start Time" => {
									type: :datetime,
									value: "47687698654678547"
					}
				}
				'
				Tempalte: {
					:body => "Hello Jonathan Leung, your email is m3@jonl.org"
				}

				GCalEvent: {
					928r3uown: {
						"Name" => {
										type: :text,
										value: "Code @ Night"
						},
						"Start Time" => {
										type: :datetime,
										value: "47687698654678547"
						}
					}
					29387492: {
						"Name" => {
										type: :text,
										value: "Code @ Night"
						},
						"Start Time" => {
										type: :datetime,
										value: "47687698654678547"
						}
					}

				}
			}
			
		}

	    
	    # Template Pipe
	    text = "Hi :::First Name::: :::Last Name:::, your email is :::Email:::"
	    template_pipe = TemplatePipe.new({
	                      :action => :fill,
	                      :template_text => text,
                        "First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
                        "Last Name" => "Trigger:Last Name"
                        "Email" => "Trigger:Email"
	                    }) 
	    template_pipe.pipeline = pipeline
	    template_pipe.save.should == true    
	    pipe_order << template_pipe.id

	    GCalPipe.new({
	    	:action => :create,
	    	:data {
	    		:calendar => "Trigger:calendar"	
	    	}
	    	
	    	:
	    })

	    # Sms Pipe
	    notification_pipe = NotificationPipe.new({
	                :action => NotificationPipe::ACTIONS[:create],
	                :type => Notification::TYPES[:sms],
	                :pipelined_references => {
	                  :phone => "Trigger:Phone Number"
	                  :body => "Templates:#{template_pipe.id}:body" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
	                }    
	               })
	    notification_pipe.pipeline = pipeline
	    notification_pipe.save.should == true
	    pipe_order << notification_pipe.id

	   	# User Pipe
	    user_pipe = UserPipe.new({ #TODO, get this from the Trigger part of the hash
	                  :action => :create,
	                  :properties => [:first_name, :last_name, ]
	                  :platform_properties_list => [:first_name, :last_name, :email, :phone, :role], 
	                  :product_properties_schema => {
	                    pennkey: String.to_s,
	                    password: String.to_s 
	                  },
	                  :default_properties => {
	                    :role => "student" #TODO, hmmm better solution?
	                  }
	                }
	    )
	    user_pipe.pipeline = pipeline
	    user_pipe.save.should == true
	    pipe_order << user_pipe.id

	    pipeline.pipe_order = pipe_order
	    pipeline.save

	    user_create_trigger_id = pipeline.create_trigger(product.id, "database:user:create", {role: "student"}) #TODO, declare channels somewhere so you won't try to set channels that don't exist
	    api_call_trigger_id = pipeline.create_trigger(product.id, "api_call", {role: "student"})    
=end
	    pp response
	    response.should_not == nil
	end
end

describe "Google Docs create_row" do
	it "should create a new row in the document" do
		client = ApiClient.new
	    google_doc_params = {
	      username: "hello@ujumbo.com",
	      password: "movefastandbreakthings",
	      file_id: "514ba494617b0023ec00000d",
	      create_new: "false",
	      #product_id: product.id,
	      schema: {
	      	"First Name" => :first_name,
	      	"Last Name" => :last_name,
	      	"Phone Number" => :phone,
	      	"Email" => :email,
	      	"Date" => :date,
	      	"Address" => :address,
	      	"Message" => :text
	      },
	      row: {
	      	"First Name" => "Kentaro",
	      	"Last Name" => "Jones",
	      	"Phone Number" => "512-587-4261",
	      	"Email" => "hacker@moore100.net",
	      	"Date" => "3/21/2013",
	      	"Address" => "Moore 100, Philadelphia PA",
	      	"Message" => "Hello world!"
	      }
	    }
	    response = client.post("/google_docs/row/create/", google_doc_params)
	    pp response
	    response.should_not == nil
	end
end

