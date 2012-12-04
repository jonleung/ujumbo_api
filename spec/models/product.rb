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

  it "can have pipelines" do
    product = Product.new
    product.name = "AirPennNet"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "Users"
    pipeline.save


    pipes = []

    pipes << = [HashWithIndifferentAccess.new({type: :trigger, subtype: :database, table: :students, on: :create}, HashWithIndifferentAccess.new({type: :trigger, subtype: :api_call})
  
    text = "Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"
    pipes << HashWithIndifferentAccess.new({type: :template, text: text, variables_hash: {:name => :student:name, :pennkey => :student:pennkey}})

    pipes << HashWithIndifferentAccess.new({type: :message, subtype: :sms, :recipeint => :student:phone}) #This should know what the previous thing was... but maybe this makes it too dependent?, set has as previous thing, maybe only looks at previous thing if there is more than one instance of it or you can directly specify what you want as the message
                                                                                                          # in the gui, it should filter by who to send it to to only variables of type students
    pipes << HashWithIndifferentAccess.new({type: :database, table: :studentsaction: :update => {:sms_sent => true} }) 

    pipeline.set = pipes

    client = ApiClient.new
    response = client.post("/pipelines/#{pipeline.id}/call", {sample_string: "sample_string"})
    response.should != nil
  end

end