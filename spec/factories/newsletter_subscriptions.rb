FactoryGirl.define do
  factory :newsletter_subscription, :class => 'Newsletter::Subscription' do
    newsletter_mailing_list
    user_profile
  end
end
