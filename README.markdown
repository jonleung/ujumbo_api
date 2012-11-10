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
stage2 = [TempafyPipe.new(template_id)]
stage 3 = SmsSendOut

pipeline.stages = [stage1, stage2, stage3]



input = GoogleDocs
Templafy
[SmsIn, Templafy]