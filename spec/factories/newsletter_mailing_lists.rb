FactoryGirl.define do
  factory :newsletter_mailing_list, :class => 'Newsletter::MailingList' do
    name { Faker::Name.name }

    trait :all_profiles do
      all_profiles true
    end

    trait :with_tag do
      tag Faker::Name.name
    end
  end
end
