module CoursesHelper

  def join_teachers(course)
    course.plannings.map(&:teacher_name).compact.uniq.join(', ')
  end

  def join_audiences(course)
    content_tag :ul, class: 'nav' do
      course.audiences.order(:order).collect do |audience|
        content_tag(:li, t(audience.name))
      end.join(', ').html_safe
    end
  end

  def join_course_subjects(course, with_h3 = false)
    course.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(',')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom') do
          link_to subject_name, subject_courses_path(subject_slug), class: 'lbl milli inline subject-link'
        end
      end
    end.join(' ').html_safe
  end

  def join_levels(course)
    content_tag :ul, class: 'nav' do
      course.levels.order(:order).collect do |level|
        content_tag(:li, t(level.name))
      end.join(', ').html_safe
    end
  end

  def join_week_days(course)
    week_days = []
    week_days = course.plannings.order(:week_day).collect do |planning|
      planning.week_day
    end.compact.uniq

    content_tag :ul, class: 'nav week_days' do
      week_days.collect do |week_day|
        content_tag(:li, t('date.day_names')[week_day])
      end.join(', ').html_safe
    end
  end
end
