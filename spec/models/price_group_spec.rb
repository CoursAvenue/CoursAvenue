require 'spec_helper'

describe PriceGroup do
  describe "#reject_price" do
    it "should accept nested attributes for prices" do
      expect(subject.send(:reject_price, { type: "Price::BookTicket", number: 1, amount: 200 })).to be_false
    end

    it "should reject a price if it is empty" do
      expect(subject.send(:reject_price, { type: "Price::BookTicket", number: 1 })).to be_true
    end
  end
end
