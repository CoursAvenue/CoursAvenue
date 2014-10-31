# encoding: utf-8
module ParticipationRequestsHelper

  def participation_request_course_description(participation_request)
    output = ''
    output << content_tag(:strong) do
      o = participation_request.course.name.dup
      o << " - #{I18n.l(participation_request.date, format: :semi_long)}"
      o << " #{l(participation_request.start_time, format: :short)} à #{l(participation_request.end_time, format: :short)}. "
      o
    end
    output << join_levels(participation_request.levels)
    output << " (#{join_audiences(participation_request.planning || participation_request.course)}), "
    output << participation_request.place.name if participation_request.place
    output.html_safe
  end

  # Print state of participation with icon and color
  #
  # @return String as HTML
  def participation_request_state_html(participation_request)
    content_tag :div, class: participation_request_color(participation_request) do
      output = ""
      output << participation_request_icon(participation_request)
      output << " "
      output << content_tag(:strong, t("participation_request.state.#{participation_request.state}"))
      output.html_safe
    end

  end

  def participation_request_color(participation_request)
    if participation_request.pending?
      'orange'
    elsif participation_request.accepted?
      'green'
    elsif participation_request.declined? or participation_request.canceled?
      'red'
    end
  end

  def participation_request_icon(participation_request)
    if participation_request.pending?
      content_tag(:i, nil, class: 'fa fa-clock')
    elsif participation_request.accepted?
      content_tag(:i, nil, class: 'fa fa-check')
    elsif participation_request.declined? or participation_request.canceled?
      content_tag(:i, nil, class: 'fa fa-times')
    end
  end

  # Description to Structure or User for a request
  # @param participation_request [type] [description]
  # @param to_whom='to_structure' [type] [description]
  #
  # @return String
  def participation_request_long_description(participation_request, resource_name='structure')
    date = "#{l(@participation_request.date, format: :semi_short)} à #{l(@participation_request.start_time, format: :short)}"
    if participation_request.pending?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html")
      end
    elsif participation_request.accepted?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, date: date, course_name: participation_request.course.name )
      end
    elsif participation_request.declined? or participation_request.canceled?
      if participation_request.last_modified_by
        t("participation_request.state.to_#{resource_name}.last_modified_by_#{participation_request.last_modified_by.downcase}.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, course_name: participation_request.course.name )
      else
        t("participation_request.state.long_description.#{participation_request.state}_html", structure_name: participation_request.structure.name, user_name: participation_request.user.name, course_name: participation_request.course.name )
      end
    end
  end

  def add_to_calendar(participation_request)
    structure  = participation_request.structure
    course     = participation_request.course
    place      = participation_request.place
    place_info = "Infos sur le lieu : #{place.info} #{place.private_info}".gsub(/\r\n/, ' ') if place.info.present? or place.private_info.present?
    # Date format
    #  <span class="_end">11-05-2012 11:38:46</span>
    # Ajouter à mon calendrier
    link = <<-eos
    <a href="#{user_participation_requests_path(current_user)}" title="Ajouter à mon calendrier" class="addthisevent">
        <div class="date">
          <span class="mon">#{t('date.abbr_month_names')[participation_request.date.month].upcase.gsub('.', '')}</span>
          <span class="day">#{participation_request.date.day}</span>
          <div class="bdr1"></div>
          <div class="bdr2"></div>
        </div>
        <div class="desc">
          <p>
            <strong class="hed">#{truncate course.name, length: 24}</strong>
            <span class="des">Lieu : #{truncate place.address, length: 28}<br />Date : #{l(participation_request.date, format: :semi_short)} à #{l(participation_request.start_time, format: :short)}</span>
          </p>
        </div>

        <span class="_start">#{l(participation_request.date)} #{l(participation_request.start_time, format: :default_only_time)}</span>
        <span class="_end">#{l(participation_request.date)} #{l(participation_request.end_time, format: :default_only_time)}</span>
        <span class="_zonecode">40</span>
        <span class="_summary">#{course.name}</span>
        <span class="_description">#{place_info}</span>
        <span class="_location">#{place.address}</span>
        <span class="_organizer">CoursAvenue en collaboration avec #{structure.name}</span>
        <span class="_organizer_email">#{structure.main_contact.email}</span>
        <span class="_all_day_event">false</span>
        <span class="_date_format">DD/MM/YYYY</span>
    </a>
    eos
    link.html_safe
  end

end
