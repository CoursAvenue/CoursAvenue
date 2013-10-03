class UpdateCoursesAndStructuresParentSubjectsStrings < ActiveRecord::Migration
  def up
    Structure.all.map(&:update_subjects_string)
    Structure.all.map(&:update_parent_subjects_string)
    Course.all.map(&:update_subjects_string)
    Course.all.map(&:update_parent_subjects_string)
  end

  def down
  end
end
