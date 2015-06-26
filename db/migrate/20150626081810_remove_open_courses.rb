class RemoveOpenCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :event_type
    remove_column :courses, :event_type_description
    Course.where(type: 'Course::Open').delete_all

    drop_table :participations
  end
end
