class CreateAudiencesCourseGroupsJoinTable < ActiveRecord::Migration
  def up
    create_table :audiences_course_groups, :id => false do |t|
      t.references :audience, :course_group
    end
    add_index :audiences_course_groups, [:audience_id, :course_group_id], :name => 'audience_course_group_index'
  end

  def down
    drop_table :audiences_course_groups
  end
end
