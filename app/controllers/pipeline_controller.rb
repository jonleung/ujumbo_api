class PipelineController < ApplicationController

  def call
    pipeline = Pipeline.find(params[:id])
    render :json => pipeline.call(params)
  end

end