class AddCourseSubjectsStringToStructure < ActiveRecord::Migration

  def up
    add_column :structures, :course_subjects_string, :text
    Structure.delay.update_course_subjects_string
  end

  def down
    remove_column :structures, :course_subjects_string
  end

end
