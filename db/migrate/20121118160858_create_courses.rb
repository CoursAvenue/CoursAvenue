class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|

      t.text    :lesson_info_1
      t.text    :lesson_info_2
      t.integer :max_age_for_kid
      t.integer :min_age_for_kid
      t.boolean :is_individual

      t.timestamps
    end
  end
end
