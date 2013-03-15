class GoogleDocsController < ApplicationController
  def callback
  	username = "hello@ujumbo.com"
    password = "movefastandbreakthings"
    
    filename = "changes_test"
    worksheet_name = "Sheet1"
  	@test_doc = GoogleDoc.new(username, password, filename, worksheet_name)
  	change = @test_doc.get_changes
  end
end
