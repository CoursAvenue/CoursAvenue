class RemoveActiveFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :active
  end
  def down
    add_column :courses, :active, :boolean
  end
end
