FactoryGirl.define do
  factory :community_membership, :class => 'Community::Membership' do
    last_notification_at { 1.day.ago }
  end
end
