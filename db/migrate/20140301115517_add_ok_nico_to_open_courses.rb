class AddOkNicoToOpenCourses < ActiveRecord::Migration
  def change
    add_column :courses, :ok_nico, :boolean, default: false
  end
end
