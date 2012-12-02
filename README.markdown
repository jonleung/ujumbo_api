



Things of intererst:

  Factory Girl
  Sinatra

  http://www.vaporbase.com/postings/Choosing_a_Schema_for_Dynamic_Records
  https://github.com/guyboertje/has_flexiblefields

  http://stackoverflow.com/questions/3943708/is-there-a-benefit-to-creating-a-very-generic-data-model-for-a-rails-3-project
  http://stackoverflow.com/questions/10723955/problems-while-making-a-generic-model-in-ruby-on-rails-3

  http://tonyandrews.blogspot.com/2004/10/otlt-and-eav-two-big-design-mistakes.html

  The idea that you need something generic actually doesnt exist...

Maybe you can have pluginnable code that you can make per application and when you see it a lot you can make it a gem easily.
This should be the main focus.

Sinatra, different types of things (get, whatever action), have a bunch of them and not some bigass thing.

Allows generality by example.

# AirPennNetAssignment
Pipeline = pipeline.new


pipeline.pipes << GoogleDocListener.new("http://docs.google.com/c80d8EdvlSEF", 
                                        

#OR

GoogleDocsPipe
  inputs
    Array
  output
    GoogleDocs: {name:String, pennkey: String, phone: Phone, sms_sent: SMS, email: Email, email_sent: Boolean}

SmsOutPipe
  inputs
    Phone
    Message
  output
    :sms_success => true / false
    :caller_phone
    :user

EmailOutPipe
  inputs
    Phone
    Message
  output
    email_sent(Boolean)


product = Product.new
pipeline = product.pipelines.new
pipeline.pipes << GoogleDocsMultiPipe.new(GoogleDoc.new({name:String, pennkey: String, phone: Phone, sms_sent: SMS, email: Email, email_sent: Boolean}))
pipeline.pipes << Templafy.new(Template.new("Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"))
pipeline.pipes << SmsOut.new("6107610083")
pipeline.pipes << UpdateDataField({:sms_sent, :sms_success})
pipeline.pipes << EmailOut.new("contact@pennapps.com")
pipeline.pipes << UpdateDataField({:email_sent, :email_success})
pipeline.save


Product = product.new
product.datasources.teachers = GoogleDoc.new({name:String, email: Email),
product.datasources.mentors = Google.new({name:String, email: Email, phone: Phone, teacher: Teacher, times_missed: Integer})

pipeline = product.pipelines.new
pipeline.pipes << GoogleDocsListener.new(google_doc)
pipeline.pipes << product.datasources.teachers.sync(google_doc_listener_id)

pipeline = product.pipelines.new
pipeline.pipes << GoogleDocsListener.new(google_doc)
pipeline.pipes << product.datasources.mentors.sync(google_doc_listener_id)

pipeline = Pipeline.new
pipeline.pipes << SmsIn(Phone.new("6103128302")) # automatically gets the user => student
pipeline.pipes << Templafy.new(Template.new("Hi :::teacher.name:::, :::student.name::: will not be able to make it to the tutoring session today")) #they get to see all avaialable variables that are autocompleted
pipeline.pipes << GoogleDocWriter(student_google_doc, {increment: :times_missed})
pipeline.pipes << 

pipeline =  Pipelinew.new
pipeline.pipes << PhoneIn(phone_id)
pipeline.pipes << StaggerCalling(["6107610083", "2412029301", "2142822129"])



pipeline.pipes << GoogleDoc.new("http://docs.google.com/c80d8EdvlSEF")
pipeline.pipes << Templafy.new(Template.new("Hi :::name:::"))
pipeline.pipes << SmsOut.new("6107610083")
pipeline.save



call(hash) {
  
  returns hash
}

pipeline.pipes < SendSms

Other QUestions:
  What do you use to send email?
  How do you do billing for say 3rd party services?

You can have special types such as Phone
that you can add into the hash that the thing knows to lookfor (maybe platform variables or something...)

Hmm, what if you made it so easy that other people can write things that plug in SO easily, that it becomes like another RACK in that it is so easy for people to write middleware for.


# Official Readme Section


## create a mysql database after installing mysql
- Make sure you have installed mysql first

start the mysql server
`mysql.server start`

If installing with HomeBrew, to set the root password:
`$(brew --prefix mysql)/bin/mysqladmin -u root YOUR_DESIRED_PASSWORD`

open a mysql console
`mysql -u root -p`

create the appropriate databases based on convention:
```
create database ujumbo_api_development;
create database ujumbo_api_test;
```

then configure your database.yml file appropriately

``` yml
# /config/database.yml
development:
  adapter: mysql2
  encoding: utf8
  database: ujumbo_api_development
  username: root
  pool: 30
  password: '1337'
  host: 127.0.0.1
  port: 3306

test:
  adapter: mysql2
  encoding: utf8
  database: ujumbo_api_test
  username: root
  pool: 30
  password: '1337'
  host: 127.0.0.1
  port: 3306

```


# Unofficial Notes and Stuffs







``` ruby

Client
  Webapp
  iPhone
  Android

User
  Roles:
    Product Specific
      Visitors
      Inputed
      Signed
      Evil

client = Client.new
client.name = "iPhone App"
client.product_id
client.signature = 
client.save

client.token=> "a0wa3fjasdmfap3wfam80dwsmf"

POST /client/post
{name: "iPhone"
 signature: "awoifawef0w3e0faefa"
}

--------

POST /user/new => HTTPS
{
  username: "a0w38fa"
  password: "a0w38faj"
}

user = User.new(username, passwrod)
=>
user_token =>



POST /user/login

"a9w3fjiemva3w0"




Create A New Pipeline

Chooose an input, (SmsIn, Google Docs Row By Row)
specify spreadsheet

pipeline = Pipeline.new
stage1 = GoogleDocsListener.new("http://drive.google.com/aw398fjasmd", :row_by_row, :include_new)
  #this sets a base url in Redis, upon incomming path, run respective pipeline
stage2 = [TempafyPipe.new(template_id)]
stage 3 = SmsSendOut


the idea is that you implicitly pass all the variables from the beginning of the pipieline
to the end of the pipeline

pipeline.input = GoogleDocsListener.listen("http://docs.google.com/3rw8efjoi")
pipeline.pipes = [TemplafyPipe.new(template_id)]
pipeline.output = SmsListener.listen(new_phone_number)
pipeline.save

pipeline.run()


Checkout Resque Scheduler

CSV






How does rack endpoints work / how does rack middlware work, use Call instead of Run
  Similar to Rack Middleware, any piece of


Pipes
  abstract to JSON / YAML now


=begin
  so say if google docs input was in the beginning of the pipeline, it would be set that
  k: "http://google.com/callbacker/id" => google docs listener
  google docs listener does a lookup in Redis to see which pipeline to all the parameters to
  it then calls the the


=end

pipeline.stages = [stage1, stage2, stage3]

POST /pipeline/:id
hash hash data




input = GoogleDocs
Templafy
[SmsIn, Templafy]

```

Sometimes it is a product specific pipeline (belongs to entire product)
Sometimes it is a user specific pipeline (only belongs to )

Lets just go through the user