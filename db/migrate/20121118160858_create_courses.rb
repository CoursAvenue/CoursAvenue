class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|

      t.text    :course_info_1
      t.text    :course_info_2
      t.text    :registration_date
      t.integer :max_age_for_kid
      t.integer :min_age_for_kid
      t.boolean :is_individual
      t.integer :annual_price_child
      t.integer :annual_price_adult
      t.boolean :annual_membership_mandatory
      t.boolean :annual_membership_mandatory
      t.boolean :is_for_handicaped

      t.timestamps
    end
  end
end
