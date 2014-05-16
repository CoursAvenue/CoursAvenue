# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :price_group, class: 'PriceGroup' do

    name 'Grille tarifaire'
    course_type 'Course::Lesson'

    factory :for_lessons do
      course_type 'Course::Training'
    end
  end
end
