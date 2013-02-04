module CoursesHelper

  def full_course_path(course)
    course_path(id: course.slug, type: course.type_name.downcase, city: course.structure.city.short_name, discipline: (course.disciplines.first ? course.disciplines.first.short_name : t('all_discipline_route_name')))
  end

  def full_course_url(course)
    course_url(id: course.slug, type: course.type_name.downcase, city: course.structure.city.short_name, discipline: (course.disciplines.first ? course.disciplines.first.short_name : t('all_discipline_route_name')))
  end

  def courses_with_old_params_path(new_params)
    p = params.reject{|key, value| value.blank? } # Get rid of the useless blank params
    courses_path(p.merge(new_params))
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
