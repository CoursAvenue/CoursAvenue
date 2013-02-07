module PlanningsHelper

  def week_day_for(planning)
    unless planning.week_day.blank?
      I18n.t('date.day_names')[planning.week_day - 1].capitalize
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

  def readable_duration(planning)
    if planning.duration.blank?
      '-'
    elsif planning.duration.hour > 0
      if planning.duration.min == 0
        "#{planning.duration.hour}h"
      else
        "#{planning.duration.hour}h#{planning.duration.min}"
      end
    else
      "#{planning.duration.min}min"
    end
  end

  def readable_time_slot(planning)
    if planning.end_time
      "#{I18n.l(planning.start_time, format: :short)} - #{I18n.l(planning.end_time, format: :short)}"
    else
      '-'
    end
  end

  def training_dates(planning)
    start_date = planning.first_day_of_training
    end_date   = planning.last_day_of_training
    if start_date == end_date
      "Le #{I18n.l(start_date)}"
    else
      "Du #{I18n.l(start_date)} au #{I18n.l(end_date)}"
    end
  end
end
