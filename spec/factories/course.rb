# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :course, class: 'Course::Lesson' do
    structure

    after(:build) do |course|
      course.subjects << course.structure.subjects.at_depth(2)
      course.prices.build type: 'Price::Trial', amount: 0
    end

    active                      true
    type                        'Course::Lesson'
    start_date                  { Date.today }
    end_date                    { Date.tomorrow }
    name                        { Faker::Lorem.sentence(4) }
    description                 { Faker::Lorem.sentence(10) }
    info                        { Faker::Lorem.sentence(4) }
    cant_be_joined_during_year   false

    factory :lesson, class: 'Course::Lesson' do
      type 'Course::Lesson'
    end
    factory :training, class: 'Course::Training' do
      type 'Course::Training'
    end

    factory :course_for_kid do
      min_age_for_kid  10
      max_age_for_kid  14
    end

    factory :individual_course do
      is_individual true
    end

    factory :handicaped_course do
      is_for_handicaped true
    end
  end
end
