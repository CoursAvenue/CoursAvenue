FactoryGirl.define do
  factory :newsletter_mailing_list, :class => 'Newsletter::MailingList' do
    newsletter
  end
end
