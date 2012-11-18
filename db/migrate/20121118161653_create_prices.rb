class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :individual_course_prce
      t.integer :annual_price
      t.integer :trimester_price
      t.integer :month_price
      t.integer :week_price
      t.integer :five_lessons_price
      t.integer :five_lessons_validity
      t.integer :ten_lessons_price
      t.integer :ten_lessons_validity
      t.integer :twenty_lessons_price
      t.integer :twenty_lessons_validity
      t.integer :thirty_lessons_price
      t.integer :thirty_lessons_validity
      t.integer :fourty_lessons_price
      t.integer :fourty_lessons_validity
      t.integer :fifty_lessons_price
      t.integer :fifty_lessons_validity
      t.integer :one_lesson_per_week_package_price
      t.integer :one_lesson_per_week_package_validity
      t.integer :two_lesson_per_week_package_price
      t.integer :two_lesson_per_week_package_validity
      t.integer :unlimited_access_price
      t.integer :unlimited_access_validity
      t.text    :excluded_lesson_from_unlimited_access_card
      t.text    :price_info_1
      t.text    :price_info_2
      t.text    :exceptional_offer
      t.text    :details_1
      t.text    :details_2
      t.boolean :is_free, :default => false

      t.references :course
      t.timestamps
    end
  end
end
