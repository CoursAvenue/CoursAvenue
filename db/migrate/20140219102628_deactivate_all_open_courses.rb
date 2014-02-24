class DeactivateAllOpenCourses < ActiveRecord::Migration
  def change
    Course::Open.update_all(active: false)
  end
end
