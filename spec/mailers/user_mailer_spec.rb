require "spec_helper"

describe UserMailer do
  describe "hello_mailer" do
    let(:mail) { UserMailer.hello_mailer }

    it "renders the headers" do
      mail.subject.should eq("Hello mailer")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
