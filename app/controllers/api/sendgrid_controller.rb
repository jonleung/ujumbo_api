class Api::SendgridController < ApiController

  def callback
    params[:from] = params[:from][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    # email_trigger_params = params.slice(:text, :html, :from, :to,)
    debugger



    render text: true
  end

  def edit_params(params)
    new_params = HashWithIndifferentAccess.new(params)



  end

end