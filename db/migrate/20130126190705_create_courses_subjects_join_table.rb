class CreateCoursesSubjectsJoinTable < ActiveRecord::Migration
  def change
    create_table :courses_subjects, :id => false do |t|
      t.references :course, :subject
    end
    add_index :courses_subjects, [:course_id, :subject_id]
  end
end
