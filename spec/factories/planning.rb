#-*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :planning do
    course
    place
    duration            10
    end_date            { Date.tomorrow }
    start_date          { Date.today }
    start_time          { Time.now }
    end_time            { Time.now + 1.hour }
    week_day            1 #
    audiences           [Audience::KID]
    levels              [Level::BEGINNER]
  end
end
