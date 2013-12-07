class CourseObserver < ActiveRecord::Observer

  def after_save(course)
    course.structure.update_meta_datas
  end
end
