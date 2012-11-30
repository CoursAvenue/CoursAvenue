module CourseGroupsHelper
  def join_audiences(course)
    content_tag :ul, class: 'nav' do
      course.audiences.uniq.collect do |audience|
        content_tag(:li, t(audience.name))
      end.join('').html_safe
    end
  end

  def join_levels(course)
    content_tag :ul, class: 'nav' do
      course.levels.uniq.collect do |level|
        content_tag(:li, t(level.name))
      end.join('').html_safe
    end
  end
end
