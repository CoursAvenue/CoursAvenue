FactoryGirl.define do
  factory :community_message_thread, :class => 'Community::MessageThread' do
    community nil
    public false
  end

end
