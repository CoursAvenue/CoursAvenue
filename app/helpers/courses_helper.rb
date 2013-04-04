module CoursesHelper

  def course_rating rating
    out = ''
    rating = rating.to_i
    5.times do |i|
      if i < rating
        out << content_tag(:i, '', class: 'icon-star yellow')
      else
        out << content_tag(:i, '', class: 'icon-star-empty')
      end
    end
    out.html_safe
  end

  def day_by_day_schedule(planning)
    schedule_string = ''
    if planning.day_one
      if planning.day_one_start_time and planning.day_one_duration
        schedule_string = I18n.t('courses.training.day_schedule', day: l(planning.day_one, format: :semi_long).capitalize, start_time: l(planning.day_one_start_time, format: :short), duration: readable_duration(planning.day_one_duration))
      end
    end
    if planning.day_two
      if planning.day_two_start_time and planning.day_two_duration
        schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_two, format: :semi_long).capitalize, start_time: l(planning.day_two_start_time, format: :short), duration: readable_duration(planning.day_two_duration))
      end
    end
    if planning.day_three
      if planning.day_three_start_time and planning.day_three_duration
        schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_three, format: :semi_long).capitalize, start_time: l(planning.day_three_start_time, format: :short), duration: readable_duration(planning.day_three_duration))
      end
    end
    if planning.day_four
      if planning.day_four_start_time and planning.day_four_duration
        schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_four, format: :semi_long).capitalize, start_time: l(planning.day_four_start_time, format: :short), duration: readable_duration(planning.day_four_duration))
      end
    end
    if planning.day_five
      if planning.day_five_start_time and planning.day_five_duration
        schedule_string += '<br>' + I18n.t('courses.training.day_schedule', day: l(planning.day_five, format: :semi_long).capitalize, start_time: l(planning.day_five_start_time, format: :short), duration: readable_duration(planning.day_five_duration))
      end
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
        content_tag(:li, t('date.day_names')[week_day])
      end.join(', ').html_safe
    end
  end
end
