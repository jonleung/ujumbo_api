class SpreadsheetsController < ApplicationController

  before_filter :ensure_current_user

  def create
    product = Product.create(name: current_user.email)
    filename = "#{params[:filename]} #{Time.now}" if params[:filename]

    google_doc_params = {
      # user_id: current_user.id,
      user: current_user,
      filename: filename,
      create_new: "true", #TODO Do we still need this?
      product: product,
      worksheets: [
        {
          name: "Users",
          schema: {
            "Timestamp" => :date,
            "First Name" => :first_name,
            "Last Name" => :last_name,
            "Email" => :email,
            "Phone" => :phone
          }
        },
        {
          name: "Email",
          schema: {
            "To" => :email,
            "Subject" => :text,
            "Body" => :text,
            "Type 'Send'" => :triggering_column
          }
        },
        {
          name: "Sms",
          schema: {
            "To" => :phone,
            "Message" => :text,
            "Type 'Send'" => :triggering_column
          }
        }
      ]
    }

    google_doc = GoogleDoc.create(google_doc_params)

    # setup pipeline to send out an email when 'send' is typed into a row in the Email worksheet
    email_pipeline = product.pipelines.new
    email_pipeline.name = "gdoc_email_pipeline#{Pipeline.count}"
    email_pipeline.save

    email_pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:update" , {google_doc_id: google_doc.id, sheet_name: "Email"} )

    email_pipe = EmailPipe.new({
      :previous_pipe_id => "first_pipe",
      :static_properties => {
        :from => current_user.email,
        },
        :pipelined_properties => {
          :to => "Trigger:To",
          :body => "Trigger:Body",
          :subject => "Trigger:Subject"
        }
    })
    email_pipe.pipeline = email_pipeline
    email_pipe.save
    email_pipeline.save


    sms_pipeline = product.pipelines.new
    sms_pipeline.name = "gdoc_sms_pipeline#{Pipeline.count}"
    sms_pipeline.save
    sms_pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:update" , {google_doc_id: google_doc.id, sheet_name: "Sms"} )

    sms_pipe = SmsPipe.new({
      :previous_pipe_id => "first_pipe",
      :static_properties => {
          :from_phone => Twilio.default_phone
        },
        :pipelined_properties => {
          :phone => "Trigger:To",
          :body => "Trigger:Message"
        }
    })
    sms_pipe.pipeline = sms_pipeline
    sms_pipe.save
    sms_pipeline.save

    #render text: "hello gdocs"
    redirect_to google_doc.url
  end

  def update
  end

  def get
  end

  def destroy
  end

  def index
  end

end