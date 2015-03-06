class PlanningDecorator < Draper::Decorator
  delegate_all

  # Audiences of the planning
  # @return:
  #   Enfant (4 à 10 ans), adultes
  def join_audiences
    audiences.map do |audience|
      if audience.kid?
        if min_age_for_kid and max_age_for_kid
          "#{I18n.t(audience.name)} (#{min_age_for_kid} à #{max_age_for_kid} ans)"
        else
          I18n.t(audience.name)
        end
      else
        I18n.t(audience.name)
      end
    end.join(', ')
  end


  # Levels of the planning
  # @return:
  #   Débutant, avancé
  def join_levels
    levels.map(&:name).map{|name| I18n.t(name)}.join(', ')
  end


  # Time slot of the planning
  # @return:
  #   -
  #   18h
  #   18h-20h
  def time_slot
    if start_time.nil? or end_time.nil?
      '-'
    elsif end_time
      "de #{I18n.l(start_time, format: :short).gsub('00', '').gsub(/^0/, '')} à #{I18n.l(end_time, format: :short).gsub('00', '').gsub(/^0/, '')}"
    else
      "à #{I18n.l(start_time, format: :short).gsub('00', '').gsub(/^0/, '')}"
    end
  end

  # Dates if it is a training
  # @return:
  #   Du lundi 3 janvier au mardi 4
  def dates
    if start_date == end_date
      "#{I18n.l(start_date, format: :semi_longer).capitalize}"
    else
      "Du #{I18n.l(start_date, format: :semi_long)} au #{I18n.l(end_date, format: :long)}"
    end
  end

  def week_day_name
    if week_day.blank?
      '-'
    else
      I18n.t('date.day_names')[week_day].capitalize
    end
  end
end
