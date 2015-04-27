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

    factory :conversation_with_messages do
      after(:create) do |conversation|
        user       = FactoryGirl.create(:user)
        structure  = FactoryGirl.create(:admin)
        receipt = user.send_message(structure, 'Body', 'Subject')
        # Hack to have messages
        receipt.notification.update_column :conversation_id, conversation.id
      end
    end

  end
end
