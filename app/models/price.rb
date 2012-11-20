class Price < ActiveRecord::Base
  belongs_to :course

  attr_accessible :individual_course_price,
                  :annual_price,
                  :semester_price,
                  :trimester_price,
                  :month_price,
                  :week_price,
                  :five_lessons_price,
                  :five_lessons_validity,
                  :ten_lessons_price,
                  :ten_lessons_validity,
                  :twenty_lessons_price,
                  :twenty_lessons_validity,
                  :thirty_lessons_price,
                  :thirty_lessons_validity,
                  :fourty_lessons_price,
                  :fourty_lessons_validity,
                  :fifty_lessons_price,
                  :fifty_lessons_validity,
                  :one_lesson_per_week_package_price,
                  :one_lesson_per_week_package_validity,
                  :two_lesson_per_week_package_price,
                  :two_lesson_per_week_package_validity,
                  :unlimited_access_price,
                  :unlimited_access_validity,
                  :excluded_lesson_from_unlimited_access_card,
                  :price_info_1,
                  :price_info_2,
                  :exceptional_offer,
                  :details_1,
                  :details_2,
                  :is_free

end
