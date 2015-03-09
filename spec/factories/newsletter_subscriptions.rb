FactoryGirl.define do
  factory :newsletter_subscription, :class => 'Newsletter::Subscription' do
    newsletter_mailing_list nil
user_profile nil
  end

end
