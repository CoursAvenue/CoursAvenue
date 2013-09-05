class AddClassDuringHolidaysForCourses < ActiveRecord::Migration
  def change
    add_column :courses, :no_class_during_holidays, :boolean
  end
end
