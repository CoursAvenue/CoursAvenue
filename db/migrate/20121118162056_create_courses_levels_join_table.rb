class CreateCoursesLevelsJoinTable < ActiveRecord::Migration
  def up
    create_table :courses_levels, :id => false do |t|
      t.references :course, :level
    end
    add_index :courses_levels, [:level_id, :course_id]
  end

  def down
    drop_table :courses_levels
  end
end
