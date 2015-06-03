FactoryGirl.define do
  factory :structure_indexable_lock, :class => 'Structure::IndexableLock' do
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
