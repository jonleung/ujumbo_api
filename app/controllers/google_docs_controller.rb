class GoogleDocsController < ApplicationController
  def callback
  	username = "hello@ujumbo.com"
    password = "movefastandbreakthings"
    
    filename = "changes_test"
    worksheet_name = "Sheet1"
  	@test_doc = GoogleDoc.new(username, password, filename, worksheet_name)
  	changes = @test_doc.trigger_changes
  end

  def create

=begin pass
  	get params {schema: {
		column_name_1: String # other options include "String", "Number"
  	}
    filename: "big_ass_spreadhsset" }
  		
=end
    # if params[:create_new].present?
    #   params[:create_new] = params[:create_new].to_bool 
    # end

    @doc = GoogleDoc.new(params)
    render text: true
  end
end
