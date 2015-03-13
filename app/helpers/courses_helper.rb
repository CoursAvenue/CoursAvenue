# encoding: utf-8
module CoursesHelper
  include ActionView::Helpers::NumberHelper

  def plain_price_range(course)
    amounts = [ course.min_price, course.max_price ].uniq

    if amounts.length > 1
      "#{number_to_currency(amounts.min)} à #{number_to_currency(amounts.max)}"
    else
      "#{number_to_currency(amounts.min)}"
    end
  end

  # Returns
  #   Case lesson:              Mardi, Jeudi, Vendredi.
  #   Case training: Lundi 23 novembre, Mardi 24 novembre, ...
  def plannings_to_come course, plannings
    if course.is_training?
      order_by = 'start_date ASC, start_time ASC'
    else
      order_by = 'week_day ASC, start_time ASC'
    end
    plannings = course.plannings.order(order_by)

    plannings_count = plannings.count
    if plannings_count > 0
      today_week_day    = Date.today.wday
      tomorrow_week_day = Date.tomorrow.wday
      string_output = ''
      if course.is_lesson?
        week_days = plannings.map do |planning|
          week_day = planning.week_day
          if week_day == today_week_day
            if planning.start_time.hour > 18
              "Ce soir"
            elsif planning.start_time.hour > 12
              "Cet après-midi"
            else
              "Ce matin"
            end
          elsif week_day == tomorrow_week_day
            'Demain'
          elsif week_day == 0 or week_day == 6
            'Ce week-end'
          else
            t('date.day_names')[week_day]
          end
        end
        string_output << week_days.uniq.join(', ')
      else
        string_output << plannings[0..3].collect{|p| training_dates(p)}.uniq.join(', ')
        if plannings_count > 3
          string_output << ', ...'
        end
      end
      string_output.html_safe
    end
    string_output.capitalize
  end

  def join_teachers(course)
    course.plannings.collect{|p| p.teacher.try(:name)}.compact.uniq.join(', ').titleize
  end

  def join_course_subjects(course)
    course.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag :span, class: 'lbl lbl--small', style: 'margin-bottom: 2px;' do
        subject_name
      end
    end.join(' ').html_safe
  end

  def join_course_subjects_text(course)
    course.subjects_string.split(';').collect do |subject_string|
      subject_string.split(':')[0]
    end.join(', ').html_safe
  end

  def join_week_days(plannings, options={})
    week_days = []
    week_days = plannings.collect do |planning|
      planning.week_day
    end.compact.uniq
    class_names = 'nav '
    class_names << options[:class]
    content_tag :ul, class: class_names do
      week_days.collect do |week_day|
        content_tag(:li, t('date.day_names')[week_day])
      end.join(', ').html_safe
    end
  end

  def readable_private_course_location(course)
    string = ""
    has_two_places = (course.teaches_at_home? and course.home_place and course.place)
    if has_two_places
      string << "<strong>2 lieux : </strong>"
    end
    if course.teaches_at_home? and course.home_place
      string << "À domicile (jusqu'à #{course.home_place.radius}km autour de #{course.home_place.city.name})"
    end
    if has_two_places
      string << " ou au "
    end
    if course.place
      string << "#{course.place.name}, #{course.place.address}"
    end
    string
  end
end
