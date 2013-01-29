# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :course do
    name               { Forgery(:lorem_ipsum).words(4) }
    description        'Lorem ipsum dolor bla bla bla'
    course_info_1      'Lorem ipsum dolor bla bla bla'
    course_info_2      'Lorem ipsum dolor bla bla bla'
    price_details      'Lorem ipsum dolor bla bla bla'
    price_info_1       'Lorem ipsum dolor bla bla bla'
    price_info_2       'Lorem ipsum dolor bla bla bla'
    teacher_name       'Tea Cher'
    trial_lesson_info  'Lorem ipsum dolor bla bla bla'
    annual_membership_mandatory true
    conditions         ''
    partner_rib_info   ''
    audition_mandatory ''
    refund_condition   ''
    cant_be_joined_during_year  {}

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
    factory :course_with_promotion do
      has_promotion true
    end
  end
end
