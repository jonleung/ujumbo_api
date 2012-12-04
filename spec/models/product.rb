require 'spec_helper'

describe "product" do

  it "can be created" do
    product = Product.new
    product.name = "AirPennNet"
    product.save.should == true
  end

  it "can have pipelines" do
    product = Product.new
    product.name = "AirPennNet"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "Users"
    pipeline.save
  end

  it "can have pipelines advanced" do
    product = Product.new
    product.name = "AirPennNet3"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "Users3"
    pipeline.save

    trigger = Trigger.create
    trigger.on = :api_call
    trigger.action = {klass: Pipeline, id: pipeline.id}
    trigger.save

    debugger

    # triggers = []
    # triggers << {type: :trigger, subtype: :database, table: :students, on: :create}
    # triggers << {type: :trigger, subtype: :params}
    # pipeline.pipes << triggers

    text = "Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"
    pipeline.pipes << {type: :template, text: text, variables_hash: {:name => "student:name", :pennkey => "student:pennkey"}}

    pipeline.pipes << {type: :message, subtype: :sms, :recipeint => "student:phone"} #This should know what the previous thing was... but maybe this makes it too dependent?, set has as previous thing, maybe only looks at previous thing if there is more than one instance of it or you can directly specify what you want as the message
                                                                                                          # in the gui, it should filter by who to send it to to only variables of type students
    pipeline.pipes << {type: :database, table: :studentsaction, :update => {:sms_sent => true} }


    client = ApiClient.new
    response = client.post("/triggers/#{trigger.id}", {sample_string: "sample_string", browser: true})
  end

end