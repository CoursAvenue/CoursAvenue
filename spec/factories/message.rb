# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :message do
    type       'Message'
    body       'Test'
    subject    'RE: Recommendation de ton cours'
    # sender     user
    # conversation_id: 1
  end
end
