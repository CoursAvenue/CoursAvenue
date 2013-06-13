class AddUniquenessIndexOnHabtmTable < ActiveRecord::Migration
  def up
    remove_index :courses_levels, [:level_id, :course_id]
    add_index :courses_levels, [:level_id, :course_id], unique: true
    remove_index :audiences_courses, name: 'audience_course_index'
    add_index :audiences_courses, [:audience_id, :course_id], unique: true
  end

  def down
    remove_index :courses_levels, [:level_id, :course_id]
    add_index :courses_levels, [:level_id, :course_id]
    remove_index :audiences_courses, name: 'audience_course_index'
    add_index :audiences_courses, [:audience_id, :course_id]
  end
end
