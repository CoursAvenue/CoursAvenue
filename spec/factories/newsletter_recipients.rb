FactoryGirl.define do
  factory :newsletter_recipient, :class => 'Newsletter::Recipient' do
    newsletter
    user_profile
    mandrill_message_id { Faker::Internet.password }
  end
end
