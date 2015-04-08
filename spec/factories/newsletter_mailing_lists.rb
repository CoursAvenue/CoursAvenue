FactoryGirl.define do
  factory :newsletter_mailing_list, :class => 'Newsletter::MailingList' do
    name { Faker::Name.name }

    trait :all_profiles do
      all_profiles true
    end
  end
end
