class GoogleDocsController < ApplicationController
  def callback
  	render :text => "Hello World"
  end
end
