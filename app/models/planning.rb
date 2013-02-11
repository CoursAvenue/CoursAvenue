class Planning < ActiveRecord::Base
  belongs_to :course
  has_many   :prices, through: :course

  attr_accessible :day_one,
                  :day_one_duration,
                  :day_one_start_time,
                  :day_two,
                  :day_two_duration,
                  :day_two_start_time,
                  :day_three,
                  :day_three_duration,
                  :day_three_start_time,
                  :day_four,
                  :day_four_duration,
                  :day_four_start_time,
                  :day_five,
                  :day_five_duration,
                  :day_five_start_time,
                  :duration,
                  :end_date,
                  :start_date,
                  :start_time, # Format: Time.parse("2000-01-01 #{value} UTC")
                  :end_time,   # Format: Time.parse("2000-01-01 #{value} UTC")
                  :week_day, # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
                  :class_during_holidays,
                  :nb_place_available,
                  :promotion,
                  :info,
                  :teacher_name,
                  :min_age_for_kid,
                  :max_age_for_kid


  def length
    if day_one.blank?
      'x'
    elsif day_five
      5
    elsif day_four
      4
    elsif day_three
      3
    elsif day_two
      2
    elsif day_one
      1
    end
  end

  def first_day_of_training
    day_one || start_date
  end

  def last_day_of_training
    if day_five
      day_five
    elsif day_four
      day_four
    elsif day_three
      day_three
    elsif day_two
      day_two
    elsif day_one
      day_one
    else
      end_date
    end
  end
end
