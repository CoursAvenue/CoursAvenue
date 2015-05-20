# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :subject do
    name { Faker::Name.name + ' child'}

    factory :subject_children do
      name { Faker::Name.name + ' child' }

      after :build do |subject|
        subject_grand_parent   = Subject.create(name: Faker::Name.name)
        # Save record before performing tree operations.
        subject_grand_parent.save
        subject_parent         = subject_grand_parent.children.create(name: Faker::Name.name)
        subject.parent         = subject_parent
        subject.ancestry_depth = 2
      end
    end

    factory :subject_with_parent do
      name { Faker::Name.name + ' parent' }
      association :parent, factory: :subject
      ancestry_depth 1
    end

    factory :subject_with_grand_parent do
      name { Faker::Name.name + ' grand parent' }
      association :parent, factory: :subject_with_parent
      ancestry_depth 2
    end

    trait :with_good_to_know do
      good_to_know { Faker::Lorem.paragraph }
    end

    trait :with_needed_meterial do
      needed_meterial { Faker::Lorem.paragraph }
    end

    trait :with_tips do
      tips { Faker::Lorem.paragraph }
    end
  end
end
