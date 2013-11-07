class CourseObserver < ActiveRecord::Observer

  def after_save(course)
    course.structure.update_synced_attributes
  end
end
