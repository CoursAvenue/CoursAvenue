# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :comment_notification do
    user
    structure

    factory :comment_notification_stage_1 do
      status 'resend_stage_1'
    end
    factory :comment_notification_stage_2 do
      status 'resend_stage_2'
    end
    factory :comment_notification_stage_3 do
      status 'resend_stage_3'
    end
    factory :comment_notification_completed do
      status 'completed'
    end
  end
end
