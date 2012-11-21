module CoursesHelper
  def join_audiences(course)
    content_tag :ul do
      course.audiences.collect do |audience|
        content_tag(:li, audience.name)
      end
    end
  end

  def join_levels(course)
    content_tag :ul do
      course.levels.collect do |level|
        content_tag(:li, level.name)
      end
    end
  end
end
