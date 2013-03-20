class GoogleDocsController < ApplicationController
  def callback
  	username = "hello@ujumbo.com"
    password = "movefastandbreakthings"
    
    filename = "changes_test"
    worksheet_name = "Sheet1"
  	@test_doc = GoogleDoc.new(username, password, filename, worksheet_name)
  	change = @test_doc.get_changes
  end

  def create

=begin
  	get params {schema: {
		column_name_1: String # other options include "String", "Number"
  	}
    filename: "big_ass_spreadhsset" }
  		
=end
    GDoc.store_schema(params[:schema], params[:filename]) if params.has_key?(:schema)
  end
end
