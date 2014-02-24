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
  #   Case workshop / training: Lundi 23 novembre, Mardi 24 novembre, ...
  def plannings_to_come course, params
    _start_date = Date.parse(params[:start_date]) if params[:start_date].present?
    _end_date   = Date.parse(params[:end_date])   if params[:end_date].present?
    # = pluralize course.plannings.future.count, 'séance'

    if course.is_lesson?
      order_by = 'week_day ASC, start_time ASC'
    else
      order_by = 'start_date ASC, start_time ASC'
    end
    plannings = course.plannings.order(order_by).where{(start_date <= _end_date) & (end_date >= _start_date)}

    if params[:week_days].present?
      plannings = plannings.reject{|p| !params[:week_days].include?(p.week_day.to_s) }
    end
    plannings_count = plannings.count
    if plannings_count > 0
      content_tag :span do
        string_output = pluralize plannings_count, 'séance'
        string_output << ' : '
        if course.is_lesson?
          string_output << join_week_days(plannings, class: 'inline').downcase
        else
          string_output << plannings[0..3].collect{|p| training_dates(p)}.join(', ').downcase
          if plannings_count > 3
            string_output << ', ...'
          end
        end
        string_output.html_safe
      end
    end
  end

  def join_teachers(course)
    course.plannings.collect{|p| p.teacher.try(:name)}.compact.uniq.join(', ').titleize
  end

  def join_course_subjects(course, with_h3 = false)
    course.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom line-height-1 inherit-font-size') do
          link_to subject_name, subject_courses_path(subject_slug), class: 'lbl milli inline subject-link'
        end
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
end
