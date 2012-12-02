require 'spec_helper'

describe "template" do
  let(:template) { create(:template, text: "Hi, my name is :::Name:::")}

  it "has one variable" do
    tempalte.variables.count == 1
  end

end