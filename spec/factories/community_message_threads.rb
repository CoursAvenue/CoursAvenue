FactoryGirl.define do
  factory :community_message_thread, :class => 'Community::MessageThread' do
    community nil
    approved false
  end

end
