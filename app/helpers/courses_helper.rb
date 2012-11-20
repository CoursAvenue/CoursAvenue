module CoursesHelper
  def join_audiences(course)
    audiences = course.audiences.collect{|audience| content_tag(:li, audience.name) }
    content_tag(:ul, audiences.join('').html_safe)
  end

  def join_levels(course)
    levels = course.levels.collect{|level| content_tag(:li, level.name) }
    content_tag(:ul, levels.join('').html_safe)
  end
end
