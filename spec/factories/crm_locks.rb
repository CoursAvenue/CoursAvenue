FactoryGirl.define do
  factory :crm_lock do
    structure

    trait :locked do
      locked true
      locked_at { 2.minutes.ago }
    end

    trait :unlocked do
      locked false
      locked_at { 1.day.ago }
    end
  end
end
