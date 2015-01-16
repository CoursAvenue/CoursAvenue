class ParticipationRequestDecorator < Draper::Decorator
  include LevelsHelper, PlanningsHelper

  delegate_all

  def status_name
    if pending? and past?
      I18n.t('participation_request.state.expired')
    else
      I18n.t("participation_request.state.#{state}")
    end
  end

  def color
    if object.pending?
      'orange'
    elsif object.accepted?
      'green'
    elsif object.declined? or object.canceled?
      'red'
    end
  end

  def popover_course_infos
    string = ""
    string << "<strong>#{(course.is_training? ? 'Stage ou atelier' : 'Cours régulier')}</strong>"
    string << "<br>"
    string << "#{join_levels(levels)}"
    string << "<br>"
    string << "#{join_audiences(planning || course)}"
    string.html_safe
  end
end
