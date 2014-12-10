# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :message, class: Mailboxer::Message do
    type       'Message'
    body       'Test'
    subject    'RE: Recommendation de ton cours'
    sender     { FactoryGirl.create(:user) }
  end

  factory :conversation, class: Mailboxer::Conversation do
    subject             'Objet'
    mailboxer_label_id  1
  end
end
