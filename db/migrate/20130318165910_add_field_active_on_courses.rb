class AddFieldActiveOnCourses < ActiveRecord::Migration
  def change
    add_column :courses, :active, :boolean, default: false
    Course.update_all(active: true)
  end
end
