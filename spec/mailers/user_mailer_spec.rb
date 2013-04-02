require "spec_helper"

describe UserMailer do
  describe "book_class" do
    let(:mail) { UserMailer.book_class }

    it "renders the headers" do
      mail.subject.should eq("Book class")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
