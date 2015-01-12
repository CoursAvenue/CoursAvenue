# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price_group, class: 'PriceGroup' do

    name 'Grille tarifaire'
    course_type 'Course::Lesson'

    factory :for_lessons do
      course_type 'Course::Training'
    end

    factory :price_group_with_prices do
      transient do
        prices_count 5
      end

      after(:build) do |price_group, evaluator|
        create_list(:price, evaluator.prices_count, price_group: price_group)
      end
    end
  end
end
