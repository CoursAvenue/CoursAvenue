# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :course do

    structure
    place

    subjects    [Subject.roots.first.children.first]
    levels      [Level.first]
    audiences   [Audience.first]

    type                        'Course::Lesson'
    name                        Forgery(:lorem_ipsum).words(4)
    description                 Forgery(:lorem_ipsum).words(10)
    info                        Forgery(:lorem_ipsum).words(4)
    price_details               'Lorem ipsum dolor bla bla bla'
    price_info                  'Lorem ipsum dolor bla bla bla'
    trial_lesson_info           'Lorem ipsum dolor bla bla bla'
    can_be_joined_during_year   false

    factory :workshop do
      type 'Course::Workshop'
    end
    factory :training do
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
