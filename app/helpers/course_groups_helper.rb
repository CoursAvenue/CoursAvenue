module CourseGroupsHelper

  def course_path(course_group)
    course_group_path(id: course_group.slug, city: course_group.structure.city, discipline: (course_group.discipline ? course_group.discipline.name : t('all_discipline_route_name')))
  end

  def course_groups_with_old_params_path(new_params)
    p = params.reject{|key, value| value.blank? } # Get rid of the useless blank params
    course_groups_path(p.merge(new_params))
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
