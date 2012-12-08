require 'spec_helper'

describe "product" do

  it "can be created" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true
  end

  it "can have pipelines" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save
  end

  it "can have triggering working" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save

    # text = "Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"
    # pipeline.pipes << TemplafyPipe.new({
    #                     :text => text,
    #                     :variables_hash => {:name => "_student:name", :pennkey => "_student:pennkey"},
    #                   })

    pipeline.set_trigger(product.id, "database:user:create", {type: "student"})

    client = ApiClient.new
    response = client.post("/triggers/#{trigger.id}", {sample_string: "sample_string", browser: true})

    pp response
    response.should_not == nil
  end

  # it "can have pipelines advanced" do
  #   product = Product.new
  #   product.name = "AirPennNet#{Product.count}"
  #   product.save.should == true

  #   #########################################
  #   # On Create User Pipeline

  #   pipeline = product.pipelines.create
  #   pipeline.name = "CreateUser#{Pipeline.count}"

  #   pipeline.pipes << UserPipe.new({ 
  #                       :action => :find_or_create,
  #                       :platform_properties => [:first_name, :last_name, :email, :phone]
  #                       :product_properties => [:pennkey => String, password: => String]
  #                       :type => "student"
  #                     })
  #   pipeline.save

  #   # Create User Pipeline
  #   trigger = product.trigger.create
  #   trigger.on = "api_call"
  #   # trigger.for is implicit because itis the id of the trigger
  #   trigger.trigger = pipeline
  #   trigger.save

  #   pipeline.triggered_by = Trigger.create("api_call")


  #   #########################################
  #   # On Create User Pipeline

  #   pipeline = product.pipelines.create
  #   pipeline.name = "OnCreateUser#{Pipeline.count}"

  #   text = "Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"
  #   pipeline.pipes << TemplafyPipe.new({
  #                       :action => :fill
  #                       :text => text,
  #                       :variables_hash => {:name => "_student:name", :pennkey => "_student:pennkey"},
  #                     })

  #   pipeline.pipes << {:pipe => Message, :subtype => :sms, :recipeint => "_student:phone", :body => "_message"}

  #   pipeline.save

  #   client = ApiClient.new
  #   response = client.post("/triggers/#{trigger.id}", {sample_string: "sample_string", browser: true})

  #   trigger = Trigger.create
  #   trigger.subscribe = "database:user:create"
  #   trigger.for = {type: "student"}
  #   trigger.trigger = pipeline

  # end

end