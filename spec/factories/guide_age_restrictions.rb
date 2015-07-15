FactoryGirl.define do
  factory :guide_age_restriction, :class => 'Guide::AgeRestriction' do
    min_age 5
    max_age 10
  end
end
