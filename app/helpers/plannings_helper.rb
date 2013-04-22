# encoding: utf-8
module PlanningsHelper

  def label_method_for_collection course_type
    case course_type
    when 'Course::Lesson'
      return lambda do |planning|
        "#{week_day_for planning} à #{l(planning.start_time, format: :short)} #{(planning.teacher.present? ? "par #{planning.teacher.name}" : '')} #{(planning.promotion.present? ? "avec #{planning.promotion}% !" : '')}"
      end
    when 'Course::Workshop'
      return lambda do |planning|
        "#{l(planning.start_date, format: :semi_long).capitalize} à #{l(planning.start_time, format: :short)} #{(planning.teacher.present? ? "par #{planning.teacher.name}" : '')} #{(planning.promotion.present? ? "avec #{planning.promotion}% !" : '')}"
      end
    when 'Course::Training'
      return lambda do |planning|
        "#{l(planning.start_date, format: :semi_long).capitalize} à #{l(planning.start_time, format: :short)} #{(planning.teacher.present? ? "par #{planning.teacher.name}" : '')} #{(planning.promotion.present? ? "avec #{planning.promotion}% !" : '')}"
      end
    end
  end

  def week_day_for(planning)
    unless planning.week_day.blank?
      I18n.t('date.day_names')[planning.week_day].capitalize
    else
      '-'
    end
  end

  def readable_promotion(planning)
    if planning.promotion.blank?
      return '-'
    else
      return "#{planning.promotion.round}%"
    end
  end

  def readable_duration time
    if time.blank?
      '-'
    elsif time.hour > 0
      if time.min == 0
        "#{time.hour}h"
      else
        "#{time.hour}h#{time.min}"
      end
    else
      "#{time.min}min"
    end
  end

  def readable_time_slot(start_time, end_time=nil)
    if start_time.nil? or end_time.nil?
      '-'
    else
      "#{I18n.l(start_time, format: :short)} - #{I18n.l(end_time, format: :short)}"
    end
  end

  def training_dates(planning)
    if planning.start_date == planning.end_date
      "#{I18n.l(planning.start_date, format: :semi_long).capitalize}"
    else
      "Du #{I18n.l(planning.start_date, format: :semi_long)} au #{I18n.l(planning.end_date, format: :semi_short)}"
    end
  end
end
