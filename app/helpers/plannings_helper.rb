# encoding: utf-8
module PlanningsHelper
  include ActionView::Helpers::NumberHelper

  def plain_price(course)
    number_to_currency(course.price)
  end

  def planning_date_for(planning)
    if planning.end_date and planning.start_date != planning.end_date
      "Du #{I18n.l(planning.start_date, format: :semi_long)} au #{I18n.l(planning.end_date, format: :semi_long)}"
    elsif planning.start_date
      "#{I18n.l(planning.start_date, format: :semi_long)}"
    end
  end

  def planning_time_for(planning, with_duration=true)
    planning_time_for_string = "de #{l(planning.start_time, format: :short)} à #{l(planning.end_time, format: :short)}"
    planning_time_for_string << " (#{readable_duration(planning.duration)})" if with_duration
    planning_time_for_string
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

  # @duration: Duration in minute
  # Return a readable duration like 1h30
  def readable_duration time_in_minutes
    return nil if time_in_minutes.nil?
    _minutes = (time_in_minutes % 60)
    minutes = _minutes < 10 ? (_minutes == 0 ? '' : "0#{_minutes}") : _minutes
    hour    = (time_in_minutes / 60).floor
    if hour == 0
      "#{minutes}min"
    else
      "#{hour}h#{minutes}"
    end
  end

  def readable_time_slot(start_time, end_time=nil)
    if start_time.nil? or end_time.nil?
      '-'
    elsif end_time
      "#{I18n.l(start_time, format: :short).gsub('00', '').gsub(/^0/, '')} - #{I18n.l(end_time, format: :short).gsub('00', '').gsub(/^0/, '')}"
    else
      "#{I18n.l(start_time, format: :short).gsub('00', '').gsub(/^0/, '')}"
    end
  end

  def training_dates(planning)
    if planning
      if planning.start_date == planning.end_date
        "#{I18n.l(planning.start_date, format: :semi_longer).capitalize}"
      else
        "Du #{I18n.l(planning.start_date, format: :semi_long)} au #{I18n.l(planning.end_date, format: :semi_shorter)}"
      end
    end
  end

  def join_audiences(planning)
    planning.audiences.map do |audience|
      if audience.kid?
        if planning.min_age_for_kid and planning.max_age_for_kid
          "#{I18n.t(audience.name)} (#{planning.min_age_for_kid} à #{planning.max_age_for_kid} ans)"
        else
          I18n.t(audience.name)
        end
      else
        I18n.t(audience.name)
      end
    end.join(', ')
  end

  def join_levels_text(planning)
    planning.levels.map(&:name).map{|name| I18n.t(name)}.join(', ')
  end
end
