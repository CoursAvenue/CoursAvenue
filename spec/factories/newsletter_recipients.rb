FactoryGirl.define do
  factory :newsletter_recipient, :class => 'Newsletter::Recipient' do
    newsletter
    user_profile
  end
end
