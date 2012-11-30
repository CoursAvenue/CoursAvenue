class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|

      t.text    :course_info_1
      t.text    :course_info_2
      t.text    :registration_date
      t.text    :teacher_name
      t.integer :max_age_for_kid
      t.integer :min_age_for_kid
      t.boolean :is_individual
      t.boolean :annual_membership_mandatory
      t.boolean :is_for_handicaped

      t.references :course_group
      t.timestamps
    end
  end
end
