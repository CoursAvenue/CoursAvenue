FactoryGirl.define do
  factory :subscription do

    trait :canceled do
      canceled_at 10.days.ago
    end

  end
end
