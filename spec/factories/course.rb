# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :course do

    association :structure

    name                        { Forgery(:lorem_ipsum).words(4) }
    description                 'Lorem ipsum dolor bla bla bla'
    course_info                 'Lorem ipsum dolor bla bla bla'
    price_details               'Lorem ipsum dolor bla bla bla'
    price_info                  'Lorem ipsum dolor bla bla bla'
    teacher_name                'Tea Cher'
    trial_lesson_info           'Lorem ipsum dolor bla bla bla'
    conditions                  ''
    partner_rib_info            ''
    audition_mandatory          ''
    refund_condition            ''
    can_be_joined_during_year   false

    # factory :course_at_nice, class: Course do
    #   association :structure_at_nice
    # end
    factory :course_for_kid do
      min_age_for_kid  10
      max_age_for_kid  14
    end

    factory :bookable_course do
      has_online_payment true
    end
    factory :individual_course do
      is_individual true
    end
    factory :handicaped_course do
      is_for_handicaped true
    end
  end
end
