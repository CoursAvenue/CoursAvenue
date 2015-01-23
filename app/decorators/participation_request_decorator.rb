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

  # Accepté|En attente|Annulé
  def long_status_name(resource_name="Structure")
    I18n.t("participation_request.state.to_#{resource_name.downcase}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}")
  end

  # <strong class="red">Annulé</strong>
  def status_for resource='Structure'
    if object.pending? and !object.past?
      html = "<strong class='#{color} has-tooltip'"
      html << "data-toggle='popover'"
      if resource == 'User' and object.last_modified_by == 'User'
        html << "data-content=\"#{I18n.t('tooltips.users.participation_requests.waiting_for_confirmation')}\""
      elsif object.last_modified_by != resource
        html << "data-content=\"#{I18n.t('tooltips.pro.participation_requests.confirm_quickly_html')}\""
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
      'blue'
    elsif object.accepted?
      'green'
    elsif object.canceled?
      'red'
    end
  end

  def popover_course_infos
    string = ""
    string << "<strong>Type : </strong>#{(course.is_training? ? 'Stage ou atelier' : 'Cours régulier')}"
    string << "<br>"
    string << "<strong>Niveau : </strong>#{join_levels(levels)}"
    string << "<br>"
    string << "<strong>Public : </strong>#{join_audiences(planning || course)}"
    string.html_safe
  end

  def action_button_name_for(resource='Structure')
    if object.past?
      I18n.t('participation_request.pro.action_button_text.report')
    elsif object.pending? and object.last_modified_by != resource
      I18n.t('participation_request.pro.action_button_text.answer_now')
    elsif object.canceled?
      I18n.t('participation_request.pro.action_button_text.view')
    else
      I18n.t('participation_request.pro.action_button_text.modify_cancel')
    end
  end

  def action_button_class_for(resource='Structure')
    if object.pending? and object.last_modified_by != resource
      'btn--green'
    end
  end

  def teacher_action_link
    if object.past?
      h.link_to action_button_name_for('Structure'),
                h.report_form_pro_structure_participation_request_path(object.structure, object),
                class: 'btn btn--small red nowrap fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name_for('Structure'),
                h.pro_structure_participation_request_path(object.structure, object),
                class: "#{action_button_class_for('Structure')} btn btn--small nowrap"
    end
  end

  def user_action_link
    if object.past?
      h.link_to action_button_name_for('User'),
                h.report_form_user_participation_request_path(object.user, object),
                class: 'btn btn--small red nowrap fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name_for('User'),
                h.user_participation_request_path(object.user, object),
                class: "btn btn--small #{action_button_class_for('User')} nowrap"
    end
  end
end
