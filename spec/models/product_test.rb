require 'spec_helper'

describe "product" do

  # it "can be created" do
  #   product = Product.new
  #   product.name = "AirPennNet#{Product.count}"
  #   product.save.should == true
  # end

  # it "can have pipelines" do
  #   product = Product.new
  #   product.name = "AirPennNet#{Product.count}"
  #   product.save.should == true

  #   pipeline = product.pipelines.new
  #   pipeline.name = "name#{Pipeline.count}"
  #   pipeline.save
  # end

  # it "triggering works without pipelining" do
  #   product = Product.new
  #   product.name = "AirPennNet#{Product.count}"
  #   product.save.should == true

  #   pipeline = product.pipelines.new
  #   pipeline.name = "name#{Pipeline.count}"
  #   pipeline.save

  #   api_call_trigger_id = pipeline.create_trigger(product.id, "api_call", {type: "student"})

  #   client = ApiClient.new
  #   response = client.post("/triggers/#{api_call_trigger_id}", {product_id: product.id, type: "student", params1: "fuck", params2: "yes", debug: "browser"})

  #   pp response
  #   response.should_not == nil
  # end

  it "user pipe is working" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save

    pipeline.pipes << UserPipe.new({ 
                        :action => UserPipe::ACTIONS[:create],
                        :key => "student",
                        :platform_properties_keys => [:first_name, :last_name, :email, :phone],
                        :product_properties_type_hash => { :pennkey => String, password: String }
                      })

    user_create_trigger_id = pipeline.create_trigger(product.id, "database:user:create", {type: "student"})
    api_call_trigger_id = pipeline.create_trigger(product.id, "api_call", {type: "student"})

    client = ApiClient.new
    response = client.post("/triggers/#{api_call_trigger_id}", {product_id: product.id, type: "student", first_name: "jonathan", last_name: "leung", phone: "610761083", email: "jonleung@seas.upenn.edu"})

    pp response
    response.should_not == nil
  end

  it "user pipe and template pipe is working" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save

    pipeline.pipes << UserPipe.new({ 
                        :action => UserPipe::ACTIONS[:create],
                        :key => "student",
                        :platform_properties_keys => [:first_name, :last_name, :email, :phone],
                        :product_properties_type_hash => { :pennkey => String, password: String }
                      })

    text = "Hi :::name:::, your PennKey is :::pennkey:::. Just reply to this message when you have successfully connected to the internet."
    pipeline.pipes << TemplatePipe.new({
                        :action => :fill,
                        :key => "message",
                        :text => text,
                        :variables_hash => {:name => "Users:student:name", :pennkey => "Users:student:pennkey"},
                      })

    user_create_trigger_id = pipeline.create_trigger(product.id, "database:user:create", {type: "student"})
    api_call_trigger_id = pipeline.create_trigger(product.id, "api_call", {type: "student"})

    client = ApiClient.new
    response = client.post("/triggers/#{api_call_trigger_id}", {product_id: product.id, type: "student", })

    pp response
    response.should_not == nil
  end

end