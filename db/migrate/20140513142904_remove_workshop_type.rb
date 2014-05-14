class RemoveWorkshopType < ActiveRecord::Migration
  def change
    courses = Course.where(type: "Course::Workshop")
    courses.update_all type: 'Course::Training'
  end
end
