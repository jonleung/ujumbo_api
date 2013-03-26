class UserMailer < ActionMailer::Base
  default from: "hello@ujumbo.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.hello_mailer.subject
  #
  def send_mail(params)
    mail params do |format|
      format.text { render :text => params[:text_body] }
      format.html { render :text => params[:html_body] }
    end
  end
end
