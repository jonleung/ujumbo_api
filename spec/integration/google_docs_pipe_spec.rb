require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
		user = User.where(email: "hello@ujumbo.com").first
		raise "Cannot find hello@ujumbo.com" if user.nil?

		product = Product.find_or_create_by(name: "PennKey")
		user.products << product
		user.save

		client = ApiClient.new

		filename = "Gdocs_pipe_31"
		google_doc_params = {
			user_id: user.id,
			filename: filename,
			create_new: "true",
			product_id: product.id,
			schema: {
				"First Name" => :first_name,
				"Last Name" => :last_name,
				"IM A TRIGGERING COLUMN" => :triggering_column
			}
		}

		google_doc = GoogleDoc.find_or_create_by(google_doc_params)

		filename = "Gdocs_pipe_32"

		google_doc_params = {
			user_id: user.id,
			filename: filename,
			create_new: "true",
			product_id: product.id,
			schema: {
				"First Name" => :first_name,
				"Last Name" => :last_name
			}
		}

		google_doc2 = GoogleDoc.find_or_create_by(google_doc_params)

		pipeline = product.pipelines.new
		pipeline.name = "name#{Pipeline.count}"
		pipeline.save.should == true

		Trigger.delete_all
		pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:create" , {google_doc_id: google_doc.id} )
		pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:destroy" , {google_doc_id: google_doc.id} )
		pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:update" , {google_doc_id: google_doc.id} )

	    # creating a row
	    gdoc_create_row_pipe = GoogleDocPipe.new({
	    	:previous_pipe_id => "first_pipe",
	    	:action => :create_row,
	    	:static_properties => {
	    		:google_doc_id => google_doc2.id,
	    		:create_by_params => {
	    			"First Name" => "This is a",
	    			"Last Name" => "Test"
	    		}
	    		},
	    		:pipelined_properties => {
	    		}
	    		})
	    gdoc_create_row_pipe.pipeline = pipeline
	    gdoc_create_row_pipe.save.should == true 

		# updating a row(s)
		# gdoc_update_row_pipe = GoogleDocPipe.new({
		# 	:previous_pipe_id => gdoc_create_row_pipe.id,
		# 	:action => :update_row,
		# 	:static_properties => {
		# 		:google_doc_id => google_doc2.id,
		# 		:find_by_params => {
		# 			"First Name" => "U",
		# 			"Last Name" => "Jumbo"
		# 			},
		# 			:update_to_params => {
		# 				"First Name" => "You",
		# 				"Last Name" => "Jumbo"
		# 			}
		# 			},
		# 			:pipelined_properties => {
		# 			}
		# 			})
		# gdoc_update_row_pipe.pipeline = pipeline
	 #    gdoc_update_row_pipe.save.should == true 

  # #   	# deleting a row(s)
  #   	gdoc_destroy_row_pipe = GoogleDocPipe.new({
  #   		:previous_pipe_id => gdoc_update_row_pipe.id,
  #   		:action => :destroy_row,
  #   		:static_properties => {
  #   			:google_doc_id => google_doc2.id,
  #   			:destroy_by_params => {
  #   				"First Name" => "You"
  #   			}
  #   			},
  #   			:pipelined_properties => {
  #   			}
  #   			})
  #   	gdoc_destroy_row_pipe.pipeline = pipeline
	 #    gdoc_destroy_row_pipe.save.should == true 
	    
		pipeline.save.should == true
	end
end
