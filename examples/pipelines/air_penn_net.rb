product = Product.new("AirPennNet")

datasource = (GoogleDoc.new(schema: {name:String, pennkey: String, phone: Phone, sms_sent: SMS, email: Email, email_sent: Boolean}, uid: :phone)) #TODO Google Doc < DataSource
product.datasource.new(type: User, table_name: "users", , datasource: datasource) 
# for each row inserted, it calls User.new for each row

# create user is only called when all the required fields are filled in

pipeline = product.pipelines.new
pipelines.pipes << datasource("users", :create_user)
=begin
  Name: "Jonathan"
  Phone: "6107610083"
  Email: "me@jonl.org"
  pennkey: "3283948234"
=end
pipelines.pipes << Templatfy.new(Template.new("Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"), type: Message)
#fills in the variables with the above hash, if it does not exist, make it an empty string
=begin
  Message: "Hi Jonathan, your pe"
=end
pipelines.pipes << SmsOut.new("6107610083", recipeint: )
#Look for Message
#Looks for Phone
=begin
  SmsSuccess: true or false
=end
pipelines.pipes << datasource("users").sync

# -OR-

pipeline.pipes << datasource("users", :update, :sms_sent)

pipeline.pipes << EmailOut.new("contact@pennapps.com")


  

pipeline.save


call (env) 

