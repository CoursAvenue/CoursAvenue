# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :message, class: Mailboxer::Message do
    type       'Message'
    body       'Test'
    subject    'RE: Recommendation de ton cours'
    # sender     user
    # conversation_id: 1
  end

  # factory :conversation, class: Mailboxer::Conversation do
  #   type       'Message'
  #   body       'Test'
  #   subject    'RE: Recommendation de ton cours'
  #   # sender     user
  #   # conversation_id: 1
  # end
end
