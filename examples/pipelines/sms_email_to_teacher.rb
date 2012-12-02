product = Product.new("Mert")
datasource = (GoogleDoc.new(schema: {name:String, pennkey: String, phone: Phone, sms_sent: SMS, email: Email, email_sent: Boolean}, uid: :phone)) #TODO Google Doc < DataSource
product.datasource.new(type: User, table_name: "teachers", , datasource: datasource) 

datasource = (GoogleDoc.new(schema: {name:String, pennkey: String, phone: Phone, sms_sent: SMS, email: Email, email_sent: Boolean}, uid: :phone)) #TODO Google Doc < DataSource
product.datasource.new(type: User, table_name: "students", , datasource: datasource) 


piipeline = product.pipelines.new
pipelines.pipes << datasource("users", :create_users)