class ParticipationRequestDecorator < Draper::Decorator
  include LevelsHelper, PlanningsHelper, PricesHelper

  delegate_all

  # Accepté|En attente|Annulé
  def status_name
    if pending? and past?
      I18n.t('participation_request.state.expired')
    else
      I18n.t("participation_request.state.#{state.state}")
    end
  end

  # Accepté|En attente|Annulé
  def long_status_name(resource_name="Structure")
    status = I18n.t("participation_request.state.to_#{resource_name.downcase}.long_description.#{participation_request.state.state}")
    if participation_request.treated?
      status += participation_request.treat_method == 'message' ?  ' (un message vous a été envoyé)' : ' (vos coordonnées de contact ont été visualisées)'
    end

    status
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
    if object.pending? and object.last_modified_by != resource
      I18n.t('participation_request.pro.action_button_text.answer_now')
    else
      I18n.t('participation_request.pro.action_button_text.view')
    end
  end

  def action_button_class_for(resource='Structure')
    if object.pending? and object.last_modified_by != resource
      'btn--green'
    else
      'btn--white'
    end
  end

  # 28 janvier de 11h00 à 12h30
  # OR
  # 28 janvier à 11h00 if it does not have planning (on appointment)
  def day_and_hour(with_end_time=true)
    if (object.course.is_private? and object.course.on_appointment?) or !with_end_time
      "#{I18n.l(object.date, format: :semi_long)} à #{I18n.l(object.start_time, format: :short).gsub('00', '')}"
    else
      "#{I18n.l(object.date, format: :semi_long)} de #{I18n.l(object.start_time, format: :short).gsub('00', '')} à #{I18n.l(object.end_time, format: :short).gsub('00', '')}"
    end
  end

  def student_home_address
    if object.street and object.zip_code and object.city
      "#{object.street}, #{object.zip_code} #{object.city.name}"
    else
      ''
    end
  end

  def details
    # XX participants, XX€ (XX x 1 cours à 29€, XX x carnets de 10 tickets à 490€)
    if object.participants.any?
      _details = h.pluralize(object.participants.map(&:number).reduce(&:+), 'participant') + ', '
      _details << "#{readable_amount object.participants.map(&:total_price).reduce(&:+)}"
      # Only show price details if there is more than one participant
      if object.participants.map(&:number).reduce(&:+) > 1
        price_details = object.participants.map.each_with_index do |participant, index|
          "#{participant.number} x #{participant.price.decorate.details.downcase}" if participant.price
        end.join(', ')
        _details << " (#{price_details})"
      end
    else
      _details = object.course.decorate.first_session_detail
    end
    _details.html_safe
  end

  def sms_message_for_new_request_to_teacher
    pr_url = h.pro_structure_participation_request_url(object.structure, object, subdomain: 'pro')
    bitly  = Bitly.client.shorten(pr_url)
    message = I18n.t('sms.structures.new_participation_request',
                     user_name: object.user.name,
                     date: I18n.l(object.date, format: :short),
                     start_time: I18n.l(object.start_time, format: :short),
                     url: bitly.short_url)
  end

  def sms_message_for_new_request_to_user
    pr_url = h.structure_website_structure_participation_request_url(object.structure, object, subdomain: 'www')
    bitly  = Bitly.client.shorten(pr_url)
    course = object.course
    default_attributes = { day:            I18n.l(object.date, format: :short),
                           start_time:     I18n.l(object.start_time, format: :short),
                           course_name:    course.name,
                           structure_name: object.structure.name,
                           url:            bitly.short_url }

    if object.course_address
      message = I18n.t('sms.users.new_participation_request.with_address',
                       default_attributes.merge({ address: object.course_address }))
    else
      message = I18n.t('sms.users.new_participation_request.without_address',
                       default_attributes)

    end
  end

  def sms_reminder_message
    pr_url = h.structure_website_structure_participation_request_url(object.structure, object, subdomain: 'www')
    bitly  = Bitly.client.shorten(pr_url)
    course = object.course
    default_attributes = { start_time: I18n.l(object.start_time, format: :short),
                           course_name: course.name,
                           structure_name: object.structure.name,
                           url: bitly.short_url }

    if object.course_address
      message = I18n.t('sms.users.day_before_reminder.one_course.with_address',
                       default_attributes.merge({ address: object.course_address }))
    else
      message = I18n.t('sms.users.day_before_reminder.one_course.without_address',
                       default_attributes)

    end
    message
  end

  def upcoming?
    object.date > Date.current
  end
end
