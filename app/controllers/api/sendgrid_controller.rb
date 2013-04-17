class Api::SendgridController < ApiController

  def callback 
    # $redis.set("last_email", Marshal.dump(params))
    params = Marshal.load($redis.get("last_email")); 
    email_trigger_params = edit_params(params)
    response = Trigger.trigger(nil, "email:receive", email_trigger_params)
    render json: email_trigger_params.to_json
  end

private

  def edit_params(params)
    new_params = HashWithIndifferentAccess.new
    new_params[:text] = clean_html(params[:html])
    new_params[:from] = params[:from][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    new_params[:to] = params[:to][/\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/]
    new_params[:google_doc_id] = /#{EmailNotification.default_heading}(.*?)@/.match(new_params[:to])[1]
    return new_params
  end

  def clean_html(html)
    d1 = Nokogiri::HTML(html)
    d1.search('blockquote').remove
    d1.css('script, link').each { |node| node.remove }
    html = d1.css('body').text.squeeze(" \n")
    html.gsub!(/\n \n/, "\n")
    html.gsub!(/\n \n/, "\n")
    html.gsub!(/^\s+/, "")
    html.sub!(/^\s*On.*2013.*@.*/m, '')
    html.lstrip!
    html.rstrip!
    return html
  end

end