#-*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :subscription_plan do
    structure

    plan_type          'monthly'
    expires_at         { Date.today + 1.month}
    renewed_at         nil
    recurrent          true
    canceled_at        nil
    credit_card_number nil
  end
end
