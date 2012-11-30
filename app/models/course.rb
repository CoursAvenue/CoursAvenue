class Course < ActiveRecord::Base

  has_one :planning
  has_one :price

  attr_accessible :course_info_1,
                  :course_info_2,
                  :max_age_for_kid,
                  :min_age_for_kid,
                  :is_individual,
                  :annual_price_adult,
                  :annual_price_child,
                  :annual_membership_mandatory,
                  :annual_membership_mandatory,
                  :is_for_handicaped,
                  :registration_date

  def is_lesson?
    false
  end

  def is_training?
    false
  end

end
