class CreateAudiencesCoursesJoinTable < ActiveRecord::Migration
  def up
    create_table :audiences_courses, :id => false do |t|
      t.references :audience, :course
    end
    add_index :audiences_courses, [:audience_id, :course_id]
  end

  def down
    drop_table :audiences_courses
  end
end
