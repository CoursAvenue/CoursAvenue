module CoursesHelper
  def join_audiences(course)
    content_tag :ul, class: 'nav' do
      course.audiences.collect do |audience|
        content_tag(:li, audience.name)
      end.reduce('')
    end
  end

  def join_levels(course)
    content_tag :ul, class: 'nav' do
      course.levels.collect do |level|
        content_tag(:li, level.name)
      end.reduce('')
    end
  end
end
