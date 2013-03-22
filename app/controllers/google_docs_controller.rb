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
    GoogleDoc.new(params)
    render text: true
  end

  def create_row
    doc = GoogleDoc.find(params[:file_id])             # want to get by id, not filename
    doc.create_row(params[:row])
    render text: true
  end
end
