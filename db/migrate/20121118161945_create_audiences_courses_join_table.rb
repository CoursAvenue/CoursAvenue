class CreateAudiencesCoursesJoinTable < ActiveRecord::Migration
  def change
    create_table :audiences_courses, :id => false do |t|
      t.references :audience, :course
    end
    add_index :audiences_courses, [:audience_id, :course_id], :name => 'audience_course_index'
  end
end
