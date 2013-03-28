require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
		user = User.where(email: "hello@ujumbo.com").first
		raise "Cannot find hello@ujumbo.com" if user.nil?

		product = Product.find_or_create_by(name: "PennKey")
		user.products << product
		user.save

		client = ApiClient.new

		filename = "Gdocs_pipe_5"
		google_doc = GoogleDoc.find_or_create_by(filename: filename)
		if google_doc.nil?
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
			response = client.post("/google_docs/spreadsheet/create/", google_doc_params)
			debugger
			google_doc = GoogleDoc.find(response["_id"])
		end

		filename = "Gdocs_pipe_2"
		google_doc2 = GoogleDoc.where(filename: filename).first
		if google_doc2.nil?
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
			response = client.post("/google_docs/spreadsheet/create/", google_doc_params)
			debugger
			google_doc2 = GoogleDoc.find(response["_id"])
		end

	    pipeline = product.pipelines.new
	    pipeline.name = "name#{Pipeline.count}"
	    pipeline.save.should == true

	    Trigger.delete_all
	    pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:create" , {google_doc_id: google_doc.id} )
	    pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:delete" , {google_doc_id: google_doc.id} )
	    pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:update" , {google_doc_id: google_doc.id} )

	    # creating a row
    	gdoc_create_row_pipe = GoogleDocPipe.new({
    			:previous_pipe_id => "first_pipe",
    			:action => :create_row,
    			:pipe_specific => {
    				:google_doc_id => google_doc2.id,
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

    	# deleting a row(s)
    	gdoc_delete_row_pipe = GoogleDocPipe.new({
    			:previous_pipe_id => "first_pipe",
    			:action => :delete_row,
    			:pipe_specific => {
    				:google_doc_id => google_doc2.id,
    				:delete_by_params => {
    					:first_name => "You"
    				}
    			},
    			:pipelined_references => {
    			}
    		})

	    pipeline.save.should == true

	end
end
