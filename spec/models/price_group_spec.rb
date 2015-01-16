require 'rails_helper'

describe PriceGroup do
  describe "#reject_price" do
    it "should accept nested attributes for prices" do
      expect(subject.send(:reject_price, { type: "Price::BookTicket", number: 1, amount: 200 })).to be(false)
    end

    it "should reject a price if it is empty" do
      expect(subject.send(:reject_price, { type: "Price::BookTicket", number: 1 })).to be(true)
    end
  end

  describe '#min_price_amount' do
    it 'return the lowest price' do
      # Prevent from saving to much stuff.
      p1 = Price::Subscription.create(amount: 240)
      p2 = Price::BookTicket.create(amount: 30, number: 1)
      allow(subject).to receive(:prices) { Price.where(id: [p1.id, p2.id]) }
      expect(subject.min_price_amount).to eq 30
    end
  end
end
