require 'spec_helper'

describe "product" do

  it "user pipe and template pipe is working" do
    product = Product.new
    product.name = "AirPennNet#{Product.count}"
    product.save.should == true

    pipeline = product.pipelines.new
    pipeline.name = "name#{Pipeline.count}"
    pipeline.save.should == true

    pipe_order = []
    # User Pipe
    user_pipe = UserPipe.new({
                  :action => UserPipe::ACTIONS[:create],
                  :platform_properties_list => [:first_name, :last_name, :email, :phone, :role],
                  :product_properties_schema => {
                    pennkey: String.to_s,
                    password: String.to_s 
                  },
                  :default_properties => {
                    :role => "student"
                  }
                }
    )
    user_pipe.pipeline = pipeline
    user_pipe.save.should == true
    pipe_order << user_pipe.id
    
    # Template Pipe
    text = "Hi :::name:::, your PennKey is :::pennkey:::. Just reply to this message when you have successfully connected to the internet."
    template_pipe = TemplatePipe.new({
                        :action => TemplatePipe::ACTIONS[:fill],
                        :template_text => text,
                        :variables_hash_schema => {
                          :name => "Users:#{user_pipe.id}:name",
                          :pennkey => "Users:#{user_pipe.id}:pennkey"
                        },
                    }) 
    template_pipe.pipeline = pipeline
    template_pipe.save.should == true    
    pipe_order << template_pipe.id

    # # Sms Pipe
    # sms_pipe = SmsPipe.new({
    #             :action => SmsPipe::ACTIONS[:send],
    #             :sender => "Users:#{user_pipe.id}:"
    #             :template => Template
    #            })
    # pipe_order << sms_pipe.id

    pipeline.pipe_order = pipe_order
    pipeline.save

    user_create_trigger_id = pipeline.create_trigger(product.id, "database:user:create", {role: "student"}) #TODO, declare channels somewhere so you won't try to set channels that don't exist
    api_call_trigger_id = pipeline.create_trigger(product.id, "api_call", {role: "student"})

    client = ApiClient.new
    student_hash = {
      first_name: "Jonathan",
      last_name: "Leung",
      email: "me@jonl.org",
      phone: "6107610083",
      pennkey: "jonleung",
      password: "wpn2"
    }
    response = client.post("/triggers/#{api_call_trigger_id}", {product_id: product.id, role: "student"}.merge(student_hash), debug: true)

    pp response
    response.should_not == nil
  end

end