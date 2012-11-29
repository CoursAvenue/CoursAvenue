class Course < ActiveRecord::Base

  has_one :plannings
  has_one :price

  attr_accessible :lesson_info_1, :lesson_info_2, :max_age_for_kid, :min_age_for_kid, :is_individual

  def is_lesson?
    false
  end

  def is_training?
    false
  end

end
