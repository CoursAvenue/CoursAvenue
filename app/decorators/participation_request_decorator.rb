class ParticipationRequestDecorator < Draper::Decorator
  include LevelsHelper, PlanningsHelper, PricesHelper

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
      elsif resource == 'Structure' and object.last_modified_by == 'Structure'
        html << "data-content=\"#{I18n.t('tooltips.pro.participation_requests.waiting_for_confirmation')}\""
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
                class: 'btn btn--small red fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name_for('Structure'),
                h.pro_structure_participation_request_path(object.structure, object),
                class: "#{action_button_class_for('Structure')} btn btn--small"
    end
  end

  def user_action_link
    if object.past?
      h.link_to action_button_name_for('User'),
                h.report_form_participation_request_path(object),
                class: 'btn btn--small red nowrap fancybox.ajax soft--sides',
                data: { behavior: 'modal', width: 500, padding: 0 }
    else
      h.link_to action_button_name_for('User'),
                h.user_participation_request_path(object.user, object),
                class: "btn btn--small #{action_button_class_for('User')} nowrap"
    end
  end

  # 28 janvier de 11h00 à 12h30
  # OR
  # 28 janvier à 11h00 if it does not have planning (on appointment)
  def day_and_hour
    if object.course.is_private? and object.course.on_appointment?
      "#{I18n.l(object.date, format: :semi_long)} à #{I18n.l(object.start_time, format: :short).gsub('00', '')}"
    else
      "#{I18n.l(object.date, format: :semi_long)} de #{I18n.l(object.start_time, format: :short).gsub('00', '')} à #{I18n.l(object.end_time, format: :short).gsub('00', '')}"
    end
  end

  def student_home_address
    "#{object.street}, #{object.zip_code} #{object.city.name}"
  end

  def details
    # XX participants, XX€ (XX x 1 cours à 29€, XX x carnets de 10 tickets à 490€)
    if object.participants.any?
      _details = h.pluralize(object.participants.map(&:number).reduce(&:+), 'participant') + ', '
      _details << "#{readable_amount object.participants.map(&:total_price).reduce(&:+)}"
      price_details = object.participants.map.each_with_index do |participant, index|
        "#{participant.number} x #{participant.price.decorate.details.downcase}" if participant.price
      end.join(', ')
      _details << " (#{price_details})"
    else
      _details = object.course.decorate.first_session_detail
    end
    _details.html_safe
  end

  def sms_message_for_new_request
    pr_url = h.structure_website_structure_participation_request_url(object.structure, object, subdomain: 'www')
    bitly  = Bitly.client.shorten(pr_url)
    course = object.course
    default_attributes = { day:            I18n.l(object.date),
                           start_time:     I18n.l(object.start_time, format: :short),
                           course_name:    course.name,
                           structure_name: object.structure.name,
                           url:            bitly.short_url }

    if object.course_address and object.structure.phone_numbers.any?
      message = I18n.t('sms.users.new_participation_request.with_address_and_phone',
                       default_attributes.merge({ address: object.course_address,
                        phone_number: object.structure.phone_numbers.first.number }))
    elsif object.course_address
      message = I18n.t('sms.users.new_participation_request.with_address',
                       default_attributes.merge({ address: object.course_address }))
    elsif object.structure.phone_numbers.any?
      message = I18n.t('sms.users.new_participation_request.with_phone',
                       default_attributes.merge({ phone_number: object.structure.phone_numbers.first.number }))
    else
      message = I18n.t('sms.users.new_participation_request.without_phone_and_address',
                       default_attributes)

    end
  end

  def sms_reminder_message
    if object.from_personal_website
      sms_reminder_message_for_pr_from_personal_websites
    else
      sms_reminder_message_for_coursavenue_users
    end
  end

  def sms_reminder_message_for_pr_from_personal_websites
    pr_url = h.structure_website_structure_participation_request_url(object.structure, object, subdomain: object.structure.subdomain_slug)
    bitly  = Bitly.client.shorten(pr_url)
    course = object.course
    default_attributes = { start_time: I18n.l(object.start_time, format: :short),
                           course_name: course.name,
                           structure_name: object.structure.name,
                           url: bitly.short_url }

    if object.course_address and object.structure.phone_numbers.any?
      message = I18n.t('sms.users.day_before_reminder.one_course.from_personal_website.with_address_and_phone',
                       default_attributes.merge({ address: object.course_address,
                        phone_number: object.structure.phone_numbers.first.number }))
    elsif object.course_address
      message = I18n.t('sms.users.day_before_reminder.one_course.from_personal_website.with_address',
                       default_attributes.merge({ address: object.course_address }))
    elsif object.structure.phone_numbers.any?
      message = I18n.t('sms.users.day_before_reminder.one_course.from_personal_website.with_phone',
                       default_attributes.merge({ phone_number: object.structure.phone_numbers.first.number }))
    else
      message = I18n.t('sms.users.day_before_reminder.one_course.from_personal_website.without_phone_and_address',
                       default_attributes)

    end
  end

  def sms_reminder_message_for_coursavenue_users
    course = object.course
    default_attributes = { start_time: I18n.l(object.start_time, format: :short),
                           course_name: course.name,
                           structure_name: object.structure.name }
    if object.course_address and object.structure.phone_numbers.any?
      message = I18n.t('sms.users.day_before_reminder.one_course.general.with_address_and_phone',
                       default_attributes.merge({ address: object.course_address,
                        phone_number: object.structure.phone_numbers.first.number }))
    elsif object.course_address
      message = I18n.t('sms.users.day_before_reminder.one_course.general.with_address',
                       default_attributes.merge({ address: object.course_address }))
    elsif object.structure.phone_numbers.any?
      message = I18n.t('sms.users.day_before_reminder.one_course.general.with_phone',
                       default_attributes.merge({ phone_number: object.structure.phone_numbers.first.number }))
    else
      message = I18n.t('sms.users.day_before_reminder.one_course.general.without_phone_and_address',
                       default_attributes)

    end

  end
end
