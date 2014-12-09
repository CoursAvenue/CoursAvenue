require 'rails_helper'

describe UnfinishedResource do

  context "UnfinishedResource::Comment" do
    let (:comment) { FactoryGirl.create(:unfinished_comment)}

    describe "#to_c" do
      it "returns a valid comment" do
        expect(comment.to_c.class.name).to eq("Comment::Review")
      end
    end

    describe "#commentable" do
      it "returns the commentable instance for the given comment" do
        expect(comment.commentable.class.name).to eq("Structure")
      end
    end

  end
end
