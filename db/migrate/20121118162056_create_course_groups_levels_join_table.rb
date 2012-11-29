class CreateCourseGroupsLevelsJoinTable < ActiveRecord::Migration
  def up
    create_table :course_groups_levels, :id => false do |t|
      t.references :course_group, :level
    end
    add_index :course_groups_levels, [:level_id, :course_group_id]
  end

  def down
    drop_table :course_groups_levels
  end
end
