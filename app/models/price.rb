class Price < ActiveRecord::Base
  belongs_to :course

  attr_accessible :individual_course_price,
                  :annual_price,
                  :semester_price,
                  :trimester_price,
                  :month_price,
                  :five_lessons_price,
                  :five_lessons_validity, # In month
                  :ten_lessons_price,
                  :ten_lessons_validity,  # In month
                  :twenty_lessons_price,
                  :twenty_lessons_validity,
                  :thirty_lessons_price,
                  :thirty_lessons_validity,
                  :fourty_lessons_price,
                  :fourty_lessons_validity,
                  :fifty_lessons_price,
                  :fifty_lessons_validity,
                  :book_tickets_a_nb,
                  :book_tickets_a_price,
                  :book_tickets_a_validity,
                  :book_tickets_b_nb,
                  :book_tickets_b_price,
                  :book_tickets_b_validity,
                  :book_tickets_c_nb,
                  :book_tickets_c_price,
                  :book_tickets_c_validity,
                  :two_lesson_per_week_package_price,
                  :unlimited_access_price,
                  :unlimited_access_validity,
                  :excluded_lesson_from_unlimited_access_card,
                  :price_info_1,
                  :price_info_2,
                  :details,
                  :is_free,
                  :promotion,
                  :student_price,
                  :young_and_senior_price,
                  :job_seeker_price,
                  :low_income_price,
                  :large_family_price,
                  :degressive_price_from_two_lesson,
                  :couple_price,
                  :has_other_preferential_price,
                  :has_exceptional_offer,
                  :trial_lesson_price,
                  :annual_registration_adult_fee,
                  :annual_registration_child_fee,
                  :price_1,
                  :price_1_libelle,
                  :price_2,
                  :price_2_libelle,
                  :approximate_price_per_course
end
