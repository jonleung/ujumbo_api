product = Product.new("CSSP Phone -> Email")

datasource = (GoogleDoc.new(schema: {First Name Last Name Email School) #TODO Google Doc < DataSource
product.datasource.new(type: User, table_name: "teachers", datasource: datasource) 

datasource = (GoogleDoc.new(schema: {First Name Last Name Email Phone School  TeacherEmail) #TODO Google Doc < DataSource
product.datasource.new(type: User, table_name: "mentors", datasource: datasource, foreign_relationship: {key_name: "TeacherEmail", table_name: "teachers"}) 
# forign_key will always be the primary key

# for each row inserted, it calls User.new for each row

# create user is only called when all the required fields are filled in

pipeline = product.pipelines.new
pipelines.pipes << SmsIn.new("6107610083")
pipelines.pipes << FindUser("sms")
=begin
  Student: {name: "Jonathan"}
  Caller: "2131231231"
  ReceivingPhone: "6107610083"
  Message: "Hi, I can't make it today, sorry!"
=end

pipelines.pipes << Templatfy.new(Template.new("Hi :::teacher.name:::, :::student.name::: cannot make it to your tutoring session at :::teacher.school:::"), type: Message)
#fills in the variables with the above hash, if it does not exist, make it an empty string
=begin
  Message: "Hi Jonathan, your pe"
=end
pipelines.pipes << Email.Out.new(from: "contact@cssp.org", to: sender.phone)
#Look for Message
#Looks for Email
=begin
  SmsSuccess: true or false
=end
pipelines.pipes << datasource("users").sync

# -OR-

pipeline.pipes << datasource("users", :update, :sms_sent)

pipeline.pipes << EmailOut.new("contact@pennapps.com")

