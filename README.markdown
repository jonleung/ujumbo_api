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