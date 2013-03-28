require 'spec_helper'

describe "Google Docs Stuff" do

  describe "Initialization" do
    it "should not be able to be saved without a user" do
      g = GoogleDoc.new
      g.save.should == false
    end

    it "should NOT be able to be saved with an unauthenticated user" do
      g = GoogleDoc.new
      g.save.should == false
    end

    it "should be able to be saved with an authenticated user" do
      g = GoogleDoc.new
      g.save.should == false
    end

  end

end 