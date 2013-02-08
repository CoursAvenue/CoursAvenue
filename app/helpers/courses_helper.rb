module CoursesHelper

  def day_by_day_schedule(planning)
    schedule_string = ''
    if planning.day_one
      schedule_string = I18n.t('courses.training.day_schedule', day: l(planning.day_one, format: :semi_short), start_time: l(planning.day_one_start_time, format: :short), duration: readable_duration(planning.day_one_duration))
    end
    if planning.day_two
      schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_two, format: :semi_short), start_time: l(planning.day_two_start_time, format: :short), duration: readable_duration(planning.day_two_duration))
    end
    if planning.day_three
      schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_three, format: :semi_short), start_time: l(planning.day_three_start_time, format: :short), duration: readable_duration(planning.day_three_duration))
    end
    if planning.day_four
      schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_four, format: :semi_short), start_time: l(planning.day_four_start_time, format: :short), duration: readable_duration(planning.day_four_duration))
    end
    if planning.day_five
      schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_five, format: :semi_short), start_time: l(planning.day_five_start_time, format: :short), duration: readable_duration(planning.day_five_duration))
    end
    return schedule_string
  end

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
        content_tag(:li, t('date.day_names')[week_day - 1])
      end.join(', ').html_safe
    end
  end
end
