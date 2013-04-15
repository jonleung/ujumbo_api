class SpreadsheetsController < ApplicationController

  def create
    user = current_user

    product = Product.create(name: user.email)
    product.save
    filename = "MVPs Rock! #{Time.now}"
    google_doc_params = {
      user_id: user.id,
      filename: filename,
      create_new: "true",
      product_id: product.id,
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
    debugger

    # setup pipeline to send out an email when 'send' is typed into a row in the Email worksheet
    email_pipeline = product.pipelines.new
    email_pipeline.name = "gdoc_email_pipeline#{Pipeline.count}"
    email_pipeline.save

    Trigger.delete_all
    email_pipeline.create_trigger(product.id, "google_docs:spreadsheet:row:update" , {google_doc_id: google_doc.id, sheet_name: "Email"} )

    email_pipe = EmailPipe.new({
      :previous_pipe_id => "first_pipe",
      :static_properties => {
        :from => user.email,
        },
        :pipelined_properties => {
          :to => "Trigger:to",
          :body => "Trigger:body",
          :subject => "Trigger:subject"
        }
    })
    email_pipe.pipeline = email_pipeline
    email_pipe.save
    email_pipeline.save

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