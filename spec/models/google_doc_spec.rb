require 'spec_helper'

describe "Google Docs Stuff" do

  describe "Initialization" do
    it "should not be able to be saved without a user" do
      g = GoogleDoc.new
      g.save.should == false
    end

    it "should NOT be able to be saved with an unauthenticated user" do
      u = User.create
      g = GoogleDoc.new(user: u)
      g.save.should == false
    end

    it "should NOT be able to be saved without setting the filename and schema" do
      u = User.where(email: "hello@ujumbo.com").first
      raise "couldn't find ujumbo user" if u.nil?
      g = GoogleDoc.new(user: u)
      debugger
      g.save.should == false
    end

    it "should be able to be saved with the proper filename, schema, and google authenticated user" do
      u = User.where(email: "hello@ujumbo.com").first
      raise "couldn't find ujumbo user" if u.nil?
      g = GoogleDoc.new(user: u, 
                        schema: {
                          "First Name" => :first_name,
                          "Last Name" => :last_name,
                          "Phone" => :phone
                        },
                        filename: "Something Awesome"
                       )
      g.save.should == true
    end

    it "should be able to be saved with the proper filename, schema, and google authenticated user" do
      pending("on the todo list")
      u = User.where(email: "hello@ujumbo.com").first
      raise "couldn't find ujumbo user" if u.nil?
        g = GoogleDoc.new(user: u, 
                          schema: {
                            "First Name" => :first_name,
                            "Last Name" => :last_name,
                            "Phone" => :phone
                          },
                          filename: "Something Awesome",
                          already_exists: true)
        g.session.should == nil
        g.save.should == true
        g.session.should_not == nil
    end

  end

  describe "retrieving a GoogleDoc" do
    it "should get an existing google doc using a where query and session should be active" do
      g = GoogleDoc.where(filename: "Something Awesome").first
      g.session.should_not == nil
    end
  end

end 