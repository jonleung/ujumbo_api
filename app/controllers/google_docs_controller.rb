class GoogleDocsController < ApplicationController
  def callback

    doc = GoogleDoc.where(key: params['key']).first
  	changes = doc.trigger_changes
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
