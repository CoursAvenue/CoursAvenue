FactoryGirl.define do
  factory :newsletter_mailing_list, :class => 'Newsletter::MailingList' do
    name { Faker::Name.name }
  end
end
