class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.decimal :individual_course_price
      t.decimal :annual_price
      t.decimal :semester_price
      t.decimal :trimester_price
      t.decimal :month_price
      t.decimal :five_lessons_price
      t.decimal :five_lessons_validity
      t.decimal :ten_lessons_price
      t.decimal :ten_lessons_validity
      t.decimal :twenty_lessons_price
      t.decimal :twenty_lessons_validity
      t.decimal :thirty_lessons_price
      t.decimal :thirty_lessons_validity
      t.decimal :fourty_lessons_price
      t.decimal :fourty_lessons_validity
      t.decimal :fifty_lessons_price
      t.decimal :fifty_lessons_validity
      t.decimal :book_tickets_a_nb
      t.decimal :book_tickets_a_price
      t.decimal :book_tickets_a_validity
      t.decimal :book_tickets_b_nb
      t.decimal :book_tickets_b_price
      t.decimal :book_tickets_b_validity
      t.decimal :book_tickets_c_nb
      t.decimal :book_tickets_c_price
      t.decimal :book_tickets_c_validity
      t.decimal :two_lesson_per_week_package_price
      t.decimal :unlimited_access_price
      t.decimal :unlimited_access_validity
      t.decimal :student_price
      t.decimal :young_and_senior_price
      t.decimal :job_seeker_price
      t.decimal :low_income_price
      t.decimal :large_family_price
      t.decimal :couple_price
      t.text    :excluded_lesson_from_unlimited_access_card
      t.text    :price_info_1
      t.text    :price_info_2
      t.boolean :has_exceptional_offer
      t.text    :details
      t.text    :promotion
      t.boolean :is_free, :default => false

      t.decimal :degressive_price_from_two_lesson
      t.boolean :has_other_preferential_price
      t.decimal :trial_lesson_price

      t.references :course
      t.timestamps
    end
  end
end
