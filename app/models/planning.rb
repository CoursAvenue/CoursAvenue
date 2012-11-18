class Planning < ActiveRecord::Base
  belongs_to :course

  attr_accessible :day_five, :day_five_duration, :day_five_start_time, :day_four, :day_four_duration, :day_four_start_time, :day_one, :day_one_duration, :day_one_start_time, :day_three, :day_three_duration, :day_three_start_time, :day_two, :day_two_duration, :day_two_start_time, :duration, :end_date, :end_time, :recurrence, :start_date, :start_time, :week_day, :class_during_holidays
end
