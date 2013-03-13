class Planning < ActiveRecord::Base
  belongs_to :course
  has_many   :prices, through: :course
  belongs_to :room

  attr_accessible :duration,
                  :end_date,
                  :start_date,
                  :start_time, # Format: Time.parse("2000-01-01 #{value} UTC")
                  :end_time,   # Format: Time.parse("2000-01-01 #{value} UTC")
                  :week_day, # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
                  :class_during_holidays,
                  :nb_place_available,
                  :promotion,
                  :info,
                  :teacher_name, # To remove
                  :min_age_for_kid,
                  :max_age_for_kid,
                  # For Trainings only
                  :day_one,               # To remove
                  :day_one_duration,      # To remove
                  :day_one_start_time,    # To remove
                  :day_two,               # To remove
                  :day_two_duration,      # To remove
                  :day_two_start_time,    # To remove
                  :day_three,             # To remove
                  :day_three_duration,    # To remove
                  :day_three_start_time,  # To remove
                  :day_four,              # To remove
                  :day_four_duration,     # To remove
                  :day_four_start_time,   # To remove
                  :day_five,              # To remove
                  :day_five_duration,     # To remove
                  :day_five_start_time    # To remove


  # 0: Dimanche, 1: Lundi, as per I18n.t('date.day_names')
  def week_day
    if read_attribute(:week_day)
      read_attribute(:week_day)
    elsif start_date
      start_date.wday
    else
      nil
    end
  end

  def length
    return (end_date - start_date).to_i
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
