class DebuggerController < ApplicationController

  def index
    debugger
    render json: true
  end

end