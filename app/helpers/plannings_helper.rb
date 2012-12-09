module PlanningsHelper
  def week_day_for(planning)
    unless planning.week_day.blank?
      I18n.t('date.day_names')[planning.week_day - 1].capitalize
    else
      '-'
    end
  end

  def readable_duration(planning)
    if planning.duration.hour > 0
      if planning.duration.min == 0
        "#{planning.duration.hour}h"
      else
        I18n.l(planning.duration, format: :short)
      end
    else
      "#{planning.duration.min}min"
    end
  end

  def readable_time_slot(planning)
    "#{I18n.l(planning.start_time, format: :short)} - #{I18n.l(planning.end_time, format: :short)}"
  end

  def training_dates(course_group)
    planning = course_group.courses.first.planning
    if planning.start_date == planning.end_date
      "Le #{I18n.l(planning.start_date)} au #{I18n.l(planning.end_date)}"
    else
      "Du #{I18n.l(planning.start_date)} au #{I18n.l(planning.end_date)}"
    end
  end
end
