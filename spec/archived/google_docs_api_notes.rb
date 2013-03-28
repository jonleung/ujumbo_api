require 'spec_helper'

describe "Google Docs create" do
	it "should create a new document" do

		product = Product.find("514a64ae1f127d9abc000001")
		client = ApiClient.new
	    google_doc_params = {
	      username: "hello@ujumbo.com",
	      password: "movefastandbreakthings",
	      filename: "test_sheet",
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
	    
	    pipeline = product.pipelines.new
	    pipeline.name = "name#{Pipeline.count}"
	    pipeline.save

	    trigger_ids = []
	    trigger_ids << pipeline.create_trigger(product.id, "google_spreadsheet:row:create",  {id: GoogleDoc.id} )

	    template_pipe = TemplatePipe.new({
	    				  :previous_action_id => -1,
	                      :action => :fill,
	                      :static_properties => {
	                      	:template_text => "Hi :::First Name::: :::Last Name:::, your email is :::Email:::", #filled 
	                      }
	                      :pipelined_properties => {
	                      	"First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
	                      	"Last Name" => "Trigger:Last Name"
	                      	"Email" => "Trigger:Email"
	                      }
	                    }) 
	    template_pipe.pipeline = pipeline
	    template_pipe.save.should == true    

=begin
	
	pipelined_hash = {
		Template: {
			243: {
				text: "Hello :::First Name:::"
			}
			244: {
				text: "Die :::First Name:::"
			}
		}
	}
	
=end

	    })

	    # Sms Pipe
	    notification_pipe = NotificationPipe.new({
	                :action => :create,
	                :static_properties => {
	                	:type => :sms,	
	                }
	                :pipelined_properties => {
	                  :phone => "Trigger:Phone Number"
	                  :body => "Templates:#{template_pipe.id}:body" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
	                }    
	               })
	    notification_pipe.pipeline = pipeline
	    notification_pipe.save.should == true
	    pipe_order << notification_pipe.id


	    pipeline.pipe_order = pipe_order
	    pipeline.save


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
=end

=begin
	pipelined_hash = {
		trigger: {
			_channel: "google_docs:spreadsheet:row:create",
			
			"Name" => {
				type: :text,
				value: "John"
			},
			"Pennkey" => {
				type: :text,
				value: "thejohn"
			},
			"Phone Number" => {
				type: :phone,
				value: "512-587-4261"
			}
			

		}
	}

	GCalPipe.new({
		:action => :create,
		:data {
			:calendar => "Trigger:calendar"	
		}
		
		:

=end
	    
		#TriggerSubclassesActions

	    # Template Pipe

