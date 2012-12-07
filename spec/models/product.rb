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

  it "can have pipelines advanced" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.create
    pipeline.name = "CreateUser#{Pipeline.count}"

    # Create User Pipeline
    trigger = product.trigger.create
    trigger.on = {:type => :api_call}
    trigger.action = {:klass => Pipeline, :id => pipeline.id}
    trigger.save


    pipeline.pipes << UserPipe.new({ 
                        :action => :find_or_create, #maybe you want a find or create here
                        :platform_properties => [:first_name, :last_name, :email, :phone ]
                        :product_properties => [:pennkey => String, password: => String]
                        :_key => "_student"
                      })

    pipeline.pipes << 
    pipeline.save

    # On Create User Pipeline

    pipeline = product.pipelines.create
    pipeline.name = "OnCreateUser#{Pipeline.count}"
    
    pipeline.pipes <<
    
    trigger = Trigger.create
    trigger.on = {:type => :database, :}

    text = "Hi :::name:::, your PennKey is :::pennkey:::. Just with anything back to this message when you have finished setting u AirPennNet"
    pipeline.pipes << {
                        :pipe => Templafy,
                        :action => :fill
                        :text => text,
                        :variables_hash => {:name => "_student:name", :pennkey => "_student:pennkey"},
                        :_key => "_message"
                      }

    pipeline.pipes << {:pipe => Message, :subtype => :sms, :recipeint => "_student:phone", :body => "_message"}

    pipeline.save

    client = ApiClient.new
    response = client.post("/triggers/#{trigger.id}", {sample_string: "sample_string", browser: true})
  end

end