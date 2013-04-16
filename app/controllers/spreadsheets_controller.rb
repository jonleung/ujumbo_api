class SpreadsheetsController < ApplicationController

  before_filter :ensure_current_user

  def create
    product = Product.create(name: current_user.email)
    filename = "#{params[:filename]} #{GoogleDoc.count}" if params[:filename]

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
            "Type 'Send'" => :triggering_column,
            "Response" => :text
          }
        },
        {
          name: "Sms",
          schema: {
            "To" => :phone,
            "Message" => :text,
            "Type 'Send'" => :triggering_column,
            "Response" => :text
          }
        }
      ]
    }

    google_doc = GoogleDoc.create(google_doc_params)


    ##########################################
    # Setup Email Sending
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


    ##########################################
    # Setup SMS Sending
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

    ##########################################
    # Setup SMS Receiving
    sms_recieve_pipeline = product.pipelines.new
    sms_recieve_pipeline.name = "gdoc_sms_recieve#{Pipeline.count}"
    sms_recieve_pipeline.save
    sms_recieve_pipeline.create_trigger(product.id, "sms:receive" , {to: PhoneHelper.standardize("4433933207")} )

    gdoc_update_row_pipe = GoogleDocPipe.new({
      :previous_pipe_id => "first_pipe",
      :action => :update_row,
      :static_properties => {
        :worksheet_name => "Sms"
        :google_doc_id => google_doc.id,
      },
      :pipelined_references => {
        :find_by_params => {
          :to => "Trigger:from"
        }
        :update_to_params => {
          :response => "Trigger:body",
        }
      }
    })

    gdoc_update_row_pipe.pipeline = sms_recieve_pipeline
    gdoc_update_row_pipe.save

    sms_pipe = SmsPipe.new({
      :previous_pipe_id => gdoc_update_row_pipe.id,
      :static_properties => {
          :body => "Awesome! We got your message!"
        },
        :pipelined_properties => {
          :phone => "Trigger:from",
        }
    })

    sms_pipe.pipeline = sms_recieve_pipeline
    sms_pipe.save




    @spreadsheets = GoogleDoc.only(:url, :filename).where(user: current_user).entries
    @spreadsheets = [] if @spreadsheets == nil

    #render text: "hello gdocs"
    @spreadsheets = GoogleDoc.only(:url, :filename).where(user: current_user).entries
    render :index
  end

  def update
  end

  def get
  end

  def destroy
  end

  def index
    @spreadsheets = GoogleDoc.only(:url, :filename).where(user: current_user).entries
    @spreadsheets = [] if @spreadsheets == nil
  end

end