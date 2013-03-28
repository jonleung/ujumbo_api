require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
		user = User.where(email: "hello@ujumbo.com").first
		raise "Cannot find hello@ujumbo.com" if user.nil?

		product = Product.find_or_create_by(name: "PennKey")
		user.products << product
		user.save

		client = ApiClient.new

		filename = "Gdocs_pipe_24"
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

		google_doc = GoogleDoc.find_or_create_by(google_doc_params)

		filename = "Gdocs_pipe_25"

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
	    	:pipe_specific => {
	    		:google_doc_id => google_doc2.id,
	    		:create_by_params => {
	    			"First Name" => "U",
	    			"Last Name" => "Jumbo"
	    		}
	    		},
	    		:pipelined_references => {
	    		}
	    		})
	    gdoc_create_row_pipe.pipeline = pipeline
	    gdoc_create_row_pipe.save.should == true 

		# updating a row(s)
		gdoc_update_row_pipe = GoogleDocPipe.new({
			:previous_pipe_id => gdoc_create_row_pipe.id,
			:action => :update_row,
			:pipe_specific => {
				:google_doc_id => google_doc2.id,
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
		gdoc_update_row_pipe.pipeline = pipeline
	    gdoc_update_row_pipe.save.should == true 

  #   	# deleting a row(s)
    	gdoc_destroy_row_pipe = GoogleDocPipe.new({
    		:previous_pipe_id => gdoc_update_row_pipe.id,
    		:action => :destroy_row,
    		:pipe_specific => {
    			:google_doc_id => google_doc2.id,
    			:destroy_by_params => {
    				:first_name => "You"
    			}
    			},
    			:pipelined_references => {
    			}
    			})
    	gdoc_destroy_row_pipe.pipeline = pipeline
	    gdoc_destroy_row_pipe.save.should == true 
	    
pipeline.save.should == true

end
end
