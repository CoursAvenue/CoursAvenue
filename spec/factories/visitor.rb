# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :visitor do
    fingerprint    Faker::Number.number(10)
    address_name   {{ "Paris" => 1, "Nice" => 2 }}

    factory :visitor_with_comment_collision do
      after(:build) do |visitor|
        comment = FactoryGirl.build(:unfinished_comment)
        visitor.comments << FactoryGirl.build(:unfinished_comment, commentable_id: comment.commentable_id)
        visitor.comments << comment
      end
    end

    factory :visitor_without_comment_collision do
      after(:build) do |visitor|
        # the factory builds commments with commentable_ids in [0, 999] so this should be good
        visitor.comments << FactoryGirl.build(:unfinished_comment)
        visitor.comments << FactoryGirl.build(:unfinished_comment, commentable_id: 9999)
      end
    end
  end
end
