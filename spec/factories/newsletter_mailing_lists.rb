FactoryGirl.define do
  factory :newsletter_mailing_list, :class => 'Newsletter::MailingList' do
    newsletter

    name { Faker::Name.name }
    tag  { Faker::Name.name }
  end
end
