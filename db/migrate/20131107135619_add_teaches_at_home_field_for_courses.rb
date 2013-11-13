class AddTeachesAtHomeFieldForCourses < ActiveRecord::Migration

  def up
    add_column :courses, :teaches_at_home, :boolean
  end

  def down
    remove_column :courses, :teaches_at_home
  end
end
