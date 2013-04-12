class SpreadsheetsController < ApplicationController

  def create
    user = current_user

    product = Product.create(name: user.email)

    filename = "MVPs Rock! #{Time.now}"
    google_doc_params = {
      user_id: user.id,
      filename: filename,
      create_new: "true",
      product_id: product.id,
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