require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
			user = User.where(email: "hello@ujumbo.com").first
			raise "Cannot find hello@ujumbo.com" if user.nil?
			debugger
			product = Product.find_or_create_by(name: "PennKey")
			user.products << product
			user.save
			
			filename = "Omniauth!"

			client = ApiClient.new

			google_doc = GoogleDoc.where(filename: filename).first
			if google_doc.nil?
				google_doc_params = {
					user_id: user.id,
				  filename: filename,
				  create_new: "true",
				  product_id: product.id,
				  schema: {
				  	"First Name" => :first_name,
				  	"Last Name" => :last_name,
				  	"Phone Number" => :phone,
				  	"Email" => :email,
				  	"To" => :to,
				  	"From" => :from,
				  	"cc" => :cc,
				  	"Subject" => :subject,
				  	"Body" => :body
				  }
				}

				response = client.post("/google_docs/spreadsheet/create/", google_doc_params)
				debugger
				google_doc = GoogleDoc.find(response["_id"])
			end

	    pipeline = product.pipelines.new
	    pipeline.name = "name#{Pipeline.count}"
	    pipeline.save.should == true

	    Trigger.delete_all
	    pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:create" , {google_doc_id: google_doc.id} )

	    # TEMPLATE
	    template_pipe = TemplatePipe.new({
	    				  :previous_pipe_id => "first_pipe",
	                      :static_properties => {
	                      	:template_text => "Hi :::First Name::: :::Last Name:::, your email is :::Email:::" #filled 
	                      },
	                      :pipelined_properties => {
	                      	"First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
	                      	"Last Name" => "Trigger:Last Name",
	                      	"Email" => "Trigger:Email"
	                      }
	                    }) 
	    template_pipe.pipeline = pipeline
	    template_pipe.save.should == true 

	    # NOTIFICATION
	    sms_pipe = SmsPipe.new({
	    			:previous_pipe_id => template_pipe.id,
	                :pipelined_properties => {
	                  :phone => "Trigger:Phone Number",
	                  :body => "Templates:#{template_pipe.id}:text" #TODO: you should not have to specify this, just the template id, and it should know what to look for, I guess instead of specifying text, you could specify a template that knows to look for text                  
	                }    
	               })
	    sms_pipe.pipeline = pipeline
	    sms_pipe.save.should == true


	    # # TEMPLATE
	    # email_template_pipe = TemplatePipe.new({
	    # 				  :previous_pipe_id => sms_pipe.id,
	    #                   :action => :fill,
	    #                   :static_properties => {
	    #                   	:template_text => "Hi :::First Name::: :::Last Name:::, your phone number is :::Phone:::" #filled 
	    #                   },
	    #                   :pipelined_properties => {
	    #                   	"First Name" => "Trigger:First Name", #TODO, thses should be made a type so that you can say, for this type, decode it, otherwise if it is just a tring then no need to decode
	    #                   	"Last Name" => "Trigger:Last Name",
	    #                   	"Phone" => "Trigger:Phone Number"
	    #                   }
	    #                 }) 
	    # email_template_pipe.pipeline = pipeline
	    # email_template_pipe.save.should == true 

	    email_pipe = EmailPipe.new({
	    			:previous_pipe_id => sms_pipe.id,
	    			:static_properties => {
	    				subject: "Hai"
	    			}
	    			:pipelined_properties => {
	    				:to => "Trigger:To",
	    				:from => "Trigger:From",
	    				:cc => "Trigger:cc",
	    				:body => "Trigger:Body",
	    				:subject => "Trigger:Subject"
	    			}
	    	})
	    email_pipe.pipeline = pipeline
	    email_pipe.save.should == true

	    # creating a row
    	gdoc_create_row_pipe = GoogleDocPipe.new({
    			:previous_pipe_id => "first_pipe",
    			:action => :create_row,
    			:pipe_specific => {
    				:google_doc_id => "9qiowekjsdf0qiowljss",
    				:create_by_params => {
    					:first_name => "U",
    					:last_name => "Jumbo"
    				}
    			},
    			:pipelined_references => {
    			}
    		})

		# updating a row(s)
    	gdoc_update_row_pipe = GoogleDocPipe.new({
    			:previous_pipe_id => "first_pipe",
    			:action => :update_row,
    			:pipe_specific => {
    				:google_doc_id => "9qiowekjsdf0qiowljss",
    				:find_by_params => {
    					:first_name => "U",
    					:last_name => "Jumbo"
    				},
    				:update_to_params => {
    					:first_name => "You",
    					:last_name => "Jumbo"
    				}
    			},
    			:pipelined_references => {
    			}
    		})

    	# deleting a row(s)
    	gdoc_delete_row_pipe = GoogleDocPipe.new({
    			:previous_pipe_id => "first_pipe",
    			:action => :update_row,
    			:pipe_specific => {
    				:google_doc_id => "9qiowekjsdf0qiowljss",
    				:delete_by_params => {
    					:first_name => "You",
    					:last_name => "Jumbo"
    				}
    			},
    			:pipelined_references => {
    			}
    		})

	    pipeline.save.should == true


	end
end
