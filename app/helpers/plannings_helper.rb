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

  def readable_duration(duration)
    if duration.blank?
      '-'
    elsif duration.hour > 0
      if duration.min == 0
        "#{duration.hour}h"
      else
        "#{duration.hour}h#{duration.min}"
      end
    else
      "#{duration.min}min"
    end
  end

  def readable_time_slot(start_time, end_time=nil)
    if end_time.nil?
      '-'
    else
      "#{I18n.l(start_time, format: :short)} - #{I18n.l(end_time, format: :short)}"
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
