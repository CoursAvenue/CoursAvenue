class ParticipationRequestDecorator < Draper::Decorator
  include LevelsHelper, PlanningsHelper

  delegate_all

  # Accepté|En attente|Annulé
  def status_name
    if pending? and past?
      I18n.t('participation_request.state.expired')
    else
      I18n.t("participation_request.state.#{state}")
    end
  end

  # <strong class="red">Annulé</strong>
  def status_for last_modified_by='Structure'
    if object.pending? and !object.past?
      html = "<strong class='#{color} has-tooltip'"
      html << "data-toggle='popover'"
      if object.last_modified_by != last_modified_by
        html << "data-content=\"#{I18n.t('tooltips.pro.participation_requests.confirm_quickly')}\""
      else
        html << "data-content=\"#{I18n.t('tooltips.pro.participation_requests.waiting_for_confirmation')}\""
      end
      html << "data-html='true' data-placement='top' data-trigger='hover'>"
    else
      html = "<strong class='#{color}'>"
    end
    html << status_name
    html << '</strong>'
    html.html_safe
  end

  # Color regarding status
  # orange|green|red
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

  def action_button_name
    if object.past?
      I18n.t('participation_request.pro.action_button_text.report')
    elsif object.pending?
      I18n.t('participation_request.pro.action_button_text.answer_now')
    else
      I18n.t('participation_request.pro.action_button_text.modify_cancel')
    end
  end

  def teacher_action_link
    if object.past?
      h.link_to action_button_name,
                h.report_form_pro_structure_participation_request_path(object.structure, object),
                class: 'btn btn--small red nowrap fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name, h.pro_structure_participation_request_path(object.structure, object), class: 'btn btn--small btn--green nowrap'
    end
  end

  def user_action_link
    if object.past?
      h.link_to action_button_name,
                h.report_form_user_participation_request_path(object.user, object),
                class: 'btn btn--small red nowrap fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name, h.user_participation_request_path(object.user, object), class: 'btn btn--small btn--green nowrap'
    end
  end
end
