require 'spec_helper'

describe "Google Docs Pipeline" do
	it "should work" do
			client = ApiClient.new
		    google_doc_params = {
		      username: "hello@ujumbo.com",
		      password: "movefastandbreakthings",
		      filename: "test_sheet#{Time.now}",
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
	end
end
