require 'rails_helper'

describe Visitor do
  describe "#best" do
    let(:visitor) { FactoryGirl.create(:visitor) }

    it "returns the histogram datum with the highest score" do
      expect(visitor.best :address_name ).to eq(["Nice", '2'])
    end
  end

  describe "#comment_collision?" do
    let(:naughty) { FactoryGirl.create(:visitor_with_comment_collision) }
    let(:nice)    { FactoryGirl.create(:visitor_without_comment_collision) }

    it "is true if the visitor has multiple comments on a single structure" do
      expect(naughty.comment_collision?).to be(true)
    end

    it "is false otherwise" do
      expect(nice.comment_collision?).to be(false)
    end
  end

  describe "#address_name=" do
    let(:visitor) { FactoryGirl.create(:visitor) }

    it "correctly merges new address data" do
      visitor.address_name = { "Paris" => 1, "Iles" => 3 }
      expect(visitor.address_name).to eq(address_name)
    end
  end

  def address_name
    {
      "Paris" => '2',
      "Nice" => '2',
      "Iles" => '3'
    }
  end
end
