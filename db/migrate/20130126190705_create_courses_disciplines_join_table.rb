class CreateCoursesDisciplinesJoinTable < ActiveRecord::Migration
  def change
    create_table :courses_disciplines, :id => false do |t|
      t.references :course, :discipline
    end
    add_index :courses_disciplines, [:course_id, :discipline_id]
  end
end
